import requests
import csv
from urllib.parse import quote
import json
ROBOT_LIBRARY_SCOPE = 'GLOBAL'

class ClashAPI():
    def __init__(self):
        self.url_base = "https://api.clashroyale.com/v1"
        self.clan_info = None
        self.players = None
        
    def set_token(self, token):
        self.token = token   
        self.headers_base = {'Authorization': f"Bearer {token}"}
    
    def get_country_id(self, country):
            
        headers = { 'Authorization': f"Bearer {self.token}" }
        url = f"{self.url_base}/locations"
        response=requests.get(url, headers=headers)
        
        if not response.ok:
            print(f"reason  = '{response.reason}'")
            print(f"status  = '{response.status}'")
            print(f"content = '{response.content}'")
            print(f"text    = '{response.text}'")
            return False
        
        locations = response.json()
        locations = locations['items']
        
        for local in locations:
            if local['name'] == country:
                print(f"'{country}' foi encontrado, o ID é: '{local['id']}'")
                return local['id']
        else:
            print(f"Country: '{country}' não foi encontrado")
            return False
    
    def get_clan(self, clan_name, filter_by_country=False, filter_by_tag=False):
        if filter_by_country:
            country_id = self.get_country_id(country=filter_by_country)
            if not country_id:
                # se não conseguiu obter o country ID, retorna False tb
                return False
            
        params = dict()
        params['name'] = clan_name
        if filter_by_country:
            params['locationId'] = country_id
            
        url = f"{self.url_base}/clans"
        
        response = requests.get(url, params=params, headers=self.headers_base)
        
        # se request não foi bem sucedido, printa as informações
        if not response.ok:
            print(f"reason  = '{response.reason}'")
            print(f"status  = '{response.status_code}'")
            print(f"content = '{response.content}'")
            print(f"text    = '{response.text}'")
            return False
        
        clans = response.json()
        clans = clans['items']
        
        if filter_by_tag:
            for guild in clans:
                if filter_by_tag in guild['tag']:
                    self.clan_info = guild
                    break
            else:
                print(f"Não consegui filtrar pela tag: '{filter_by_tag}'")
                return False
        else:
            self.clan_info = clans
            
        # se foi bem sucedido, apenas salva e retorna o JSON
        return self.clan_info
    
    def list_clan_members(self):
        if not self.clan_info:
            print('Nenhum clã especificado para listar membros')
            return False
        if not isinstance(self.clan_info, list):
            self.clan_info = [self.clan_info]
        
        for clan in self.clan_info:
            print('tag = ', clan['tag'])
        
            tag = quote(clan['tag'])
            url = fr"{self.url_base}/clans/{tag}/members"
            
            response = requests.get(url, headers=self.headers_base)
            
            if not response.ok:
                print(f"reason  = '{response.reason}'")
                print(f"status  = '{response.status_code}'")
                print(f"content = '{response.content}'")
                print(f"text    = '{response.text}'")
                return False
            
            players = response.json()
            self.players = players['items']
            return self.players
        
    def prime_control_export_csv(self, output_file_path):
        """método específico para exportar os dados necessários da Prime Control :)"""
        if self.players is None:
            print(f"Não existem dados para serem exportados como CSV")
            return False 
        try:
            with open(output_file_path, 'w',encoding='utf-8', newline="") as csv_file:
                csv_writer = csv.DictWriter(csv_file, delimiter = ",", fieldnames = ["Nome", "Level", "Troféu", "Papel"])
                csv_writer.writeheader()
                for info in self.players:
                    data_to_write = {
                        "Nome"  :  info["name"],
                        "Level" :  info["expLevel"],
                        "Troféu":  info["trophies"],
                        "Papel" :  info["role"]
                    }
                    csv_writer.writerow(data_to_write)
        except Exception as e:
            print(f"Erro '{e}' ocorreu ao gerar o arquivo CSV")
            return False
        print(f"Arquivo '{output_file_path}' foi criado com sucesso")
        return True
            
def __testes():
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiIsImtpZCI6IjI4YTMxOGY3LTAwMDAtYTFlYi03ZmExLTJjNzQzM2M2Y2NhNSJ9.eyJpc3MiOiJzdXBlcmNlbGwiLCJhdWQiOiJzdXBlcmNlbGw6Z2FtZWFwaSIsImp0aSI6IjBiMWVlMTNhLTRiOTUtNDBhZi05YTFkLTY0YTdhZWNlMzhiZiIsImlhdCI6MTYzNjE0OTk4Nywic3ViIjoiZGV2ZWxvcGVyL2JjZDk0ODlhLWY4MTYtM2VhYy1hODM1LTU0MmY5MTIzY2ExOSIsInNjb3BlcyI6WyJyb3lhbGUiXSwibGltaXRzIjpbeyJ0aWVyIjoiZGV2ZWxvcGVyL3NpbHZlciIsInR5cGUiOiJ0aHJvdHRsaW5nIn0seyJjaWRycyI6WyIxNzcuNzMuMTExLjgzIl0sInR5cGUiOiJjbGllbnQifV19.OUPJ03x6Bh7mbSae-RlhFLXJMQkvlhIGjkgRit--fr0Vpu7IEpgbZ7uI7NDPc9Z4Z12NAMkVUX9Lbj2Us53QnA"
    clash_api = ClashAPI(api_token=token)

    # retorno = clash_api.list_clan_members()
    # print(retorno)

    # country_id = clash_api.get_country_id("Brazil")
    # print(f"country_id = '{country_id}'")
    
    guilds = clash_api.get_clan("Resistance", filter_by_country="Brazil", filter_by_tag="#9V2Y")
    # print(json.dumps(guilds, indent=2))
    
    retorno = clash_api.list_clan_members()
    print(retorno)
    
    clash_api.prime_control_export_csv(r"D:\git\meus cods\robot framework\test\export.csv")
    
    # retorno = clash_api.get_clan("Resistance")
    # print(json.dumps(retorno, indent=2))

if __name__ == '__main__':
    __testes()