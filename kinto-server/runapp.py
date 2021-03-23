# #!/usr/bin/env python
# import os

# from paste.deploy import loadapp
# from waitress import serve

# from pathlib import Path
# from dotenv import load_dotenv
# load_dotenv(verbose=True)
# env_path = Path('.') / '.env'

# print("Something")
# if __name__ == "__main__":
#     print("Main thing")

#     database = os.getenv("DATABASE_URL")

#     if not database:
#         raise ValueError("DATABASE_URL is not correctly defined: %s" %
#                          database)

#     app = loadapp('config:kinto.ini', relative_to='.')


#     serve(app, host='0.0.0.0', port=5000)
