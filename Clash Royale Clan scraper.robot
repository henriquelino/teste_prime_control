*** Settings ***
Library    OperatingSystem
Library    Selenium2Library
Library    Collections
Library    String
Library    get_ip.py
Library    ClashAPI.py
Variables    vars.yml


Suite Setup       Include Browser Drivers
Suite Teardown    Close All Browsers

*** Variables ***
${browser}    chrome
${csv_output_path}    ${EXECDIR}/result.csv

# ---------- Clã ----------

# ---------- Login ----------
${login_url}    https://developer.clashroyale.com/#/login
${login_email_field}    id=email
${login_password_field}    id=password
${login_botao_login}    xpath=//*[@id="content"]/div/div[2]/div/div/div/div/div/div/form/div[4]/button
${login_sure}    dom=document.getElementsByClassName("dropdown-toggle__text")[0]

# ---------- Criar KEY ----------
${new_key_url}    https://developer.clashroyale.com/#/new-key
${new_key_name}    id=name
${new_key_description}    id=description
${new_key_allowed_ip_addresses}    id=range-0
${new_key_botao_create_key}    dom=document.getElementsByClassName("ladda-label")[0]
${new_key_created_sure}    xpath=//*[@id="content"]/div/div[2]/div/div/section[2]/div/div/div[2]/ul/div
${key_created_message}    Key created successfully.

# ---------- Seleciona Token ----------
${primeiro_token_da_lista}    xpath=//*[@id="content"]/div/div[2]/div/div/section[2]/div/div/div[2]/ul/li[1]
${elemento_token}    xpath=//*[@id="content"]/div/div[2]/div/div/section/div/div/div[2]/form/div[1]/div/samp

# ---------- Exclui ----------
${botao_excluir_token}    xpath=//*[@id="content"]/div/div[2]/div/div/section/div/div/div[2]/form/div[5]/button/span[1]
${exclusao_sure}    xpath=//*[@id="content"]/div/div[2]/div/div/section[2]/div/div/div[2]/ul/div/span[3]
${exclusao_sure_msg}     Key deleted successfully.


*** Test Cases ***
Loga Clash Royale API
    Log    Logando no Clash Royale    INFO

    Log    Abrindo google chrome    DEBUG
    Open Browser    ${login_url}    ${browser}
    Log    Maximizando navegador    DEBUG
    Maximize Browser Window


    Log    Aguardando campo de e-mail     DEBUG
    Wait Until Element Is Visible    ${login_email_field}
    Log    Preenchendo campo com '${email}'     INFO
    Input Text    ${login_email_field}    ${email}


    Log    Aguardando campo password     DEBUG
    Wait Until Element Is Visible    ${login_password_field}
    Log    Preenchendo campo password '${password}'     INFO
    Input Text    ${login_password_field}    ${password}
    

    Log    Aguardando botão Login     DEBUG
    Wait Until Element Is Visible    ${login_botao_login}
    Log    Clicando no botão Login     INFO
    Click Element    ${login_botao_login}


    Log    Validando se logou com sucesso     DEBUG
    Wait Until Element Is Visible    ${login_sure}
    ${username}    Get Text    ${login_sure}

    IF    "${login_account_name}" != "${username}"  
        Log    Obtido '${login_account_name}' porém  esperava '${username}'     ERROR
        Fail    Nao logou na conta correta
    END

Cria Token API no Clash Royale
    Log    Obtendo o IP externo da máquina    DEBUG
    ${ip} =    Get Ip
    IF    "${ip}" == "False"
        Fail    Falha ao obter o IP
    END
    Log    Ip obtido: ${ip}    DEBUG


    Log    Criando um novo Token no Clash Royale    INFO
    Go To    ${new_key_url}


    Log    Aguardando campo Key Name     DEBUG
    Wait Until Element Is Visible    ${new_key_name}
    ${nome_da_nova_chave}    Generate random string    4    0123456789
    ${nome_da_nova_chave} =   Catenate    chave_${nome_da_nova_chave} 
    Log    Preenchendo campo com ${nome_da_nova_chave}     INFO
    Input Text    ${new_key_name}    ${nome_da_nova_chave}


    Log    Aguardando campo Description    DEBUG
    Wait Until Element Is Visible    ${new_key_description}
    ${description_da_nova_chave}    Generate random string    4    0123456789
    ${description_da_nova_chave} =    Catenate    desc_chave_${description_da_nova_chave} 
    Log    Preenchendo campo com ${description_da_nova_chave}     INFO
    Input Text    ${new_key_description}    ${description_da_nova_chave}


    Log    Aguardando campo Allowed IP Address     DEBUG
    Wait Until Element Is Visible    ${new_key_allowed_ip_addresses}
    Log    Preenchendo campo com ${ip}     INFO
    Input Text    ${new_key_allowed_ip_addresses}    ${ip}


    Log    Aguardando botão 'Create Key'     DEBUG
    Wait Until Element Is Visible    ${new_key_botao_create_key}
    Log    Clicando em Create Key     INFO
    Click Element    ${new_key_botao_create_key}


    Log    Verificando se chave foi criada     DEBUG
    Wait Until Element Is Visible    ${new_key_created_sure}
    ${key_created}    Get Text    ${new_key_created_sure}
    Log    Obtido o valor '${key_created}'     INFO
    
    IF    "${key_created}" != "${key_created_message}"  
        Log    Obtido '${key_created}' porém  esperava '${key_created_message}'     ERROR
        Fail    Nao encontrei mensagem de confirmacao na criacao da chave
    END

Obtem chave do Token
    Log    Obtendo a Chave do token criado     INFO

    Log    Aguardando elemento da primeira key     DEBUG
    Wait Until Element Is Visible    ${primeiro_token_da_lista}
    Log    Clicando na primeira key     INFO
    Click Element    ${primeiro_token_da_lista}


    Log    Aguardando elemento da chave aparecer     DEBUG
    Wait Until Element Is Visible    ${elemento_token}
    ${api_token}    Get Text    ${elemento_token}

    Log    Token obtido: ${api_token}    INFO

    Set Global Variable      ${api_token} 


Cria Planilha

    Log    Setando token da classe    INFO
    ${retorno}=    Set Token    ${api_token}
    IF    "${retorno}" == "False"
        Fail    Falha ao setar o Token
    END
    Log    Token setado com sucesso    DEBUG


    Log    Obtendo informações do clã    INFO
    ${retorno}=    Get Clan    ${clan_name}    ${clan_country}    ${clan_tag_like}
    IF    "${retorno}" == "False"
        Fail    Falha ao obter informações do Clã: Nome: '${clan_name}' | País: '${clan_country}' | Tag: '${clan_tag_like}'
    END
    Log    Infos do clã obtidas com sucesso    DEBUG
    

    Log    Listando membros do clã    INFO
    ${retorno}=    List Clan Members
    IF    ${retorno} == "False"
        Fail    Falha ao listar membros do Clã: Nome: '${clan_name}' | País: '${clan_country}' | Tag: '${clan_tag_like}'
    END
    Log    Membros listados com sucesso    DEBUG
    
    
    Log    Exportando membros para o arquivo ${csv_output_path}    INFO
    ${retorno}=    Prime Control Export Csv    ${csv_output_path}
    IF    "${retorno}" == "False"
        Fail    Falha ao exportar CSV para o caminho: '${csv_output_path}'. Não esqueça de abrir o arquivo com o encoding UTF-8
    END
    Log    CSV exportado com sucesso    DEBUG

Deleta Token
    Log    Aguardando botão de Excluir     INFO
    Wait Until Element Is Visible    ${botao_excluir_token}
    Log    Clicando em excluir     DEBUG
    Click Element    ${botao_excluir_token}

    Log    Verificando se a chave foi excluida     INFO
    Wait Until Element Is Visible    ${exclusao_sure}
    ${exclusao_msg}    Get Text    ${exclusao_sure}
    Log    Mensagem obtida: '${exclusao_msg}'     INFO

    
    IF    "${exclusao_msg}" != "${exclusao_sure_msg}"  
        Fail    Nao encontrei mensagem de confirmacao na criacao da chave
    END


*** Keywords ***
Include Browser Drivers
    Append To Environment Variable    PATH    ${EXECDIR}/webdriver
