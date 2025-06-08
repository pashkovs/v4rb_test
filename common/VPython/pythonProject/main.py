import valentina

def print_version():
  
    conn = valentina.connect()

    cursor = conn.cursor()
    cursor.execute('SELECT version()')
    version = cursor.fetchone()
    print(f"Valentina Version: {version[0]}")
    
    conn.close()

if __name__ == '__main__':
    print_version()
