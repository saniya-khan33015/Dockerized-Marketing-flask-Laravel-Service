import os
import time
from dotenv import load_dotenv
load_dotenv()

import mysql.connector
from flask import Flask, render_template, request, flash, redirect, url_for
from mysql.connector import Error

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'dev_key_very_secret')

# Database Configuration (Environment Variables)
db_config = {
    'host': os.environ.get('DB_HOST', 'localhost'),
    'user': os.environ.get('DB_USER', 'root'),
    'password': os.environ.get('DB_PASSWORD', ''),
    'database': os.environ.get('DB_NAME', 'marketing_db')
}


def get_db_connection(retries=5, delay=3):
    """Establishes and returns a database connection with retry logic."""
    for i in range(retries):
        try:
            connection = mysql.connector.connect(**db_config)
            if connection.is_connected():
                return connection
        except Error as e:
            print(f"Database connection failed. Retrying... ({i+1}/{retries})")
            time.sleep(delay)
    return None


def init_db():
    """Initializes the database and table."""
    print("Initializing database...")

    try:
        # Connect without specifying DB first
        temp_config = db_config.copy()
        temp_config.pop('database')

        conn = mysql.connector.connect(**temp_config)
        if conn.is_connected():
            cursor = conn.cursor()
            cursor.execute("CREATE DATABASE IF NOT EXISTS marketing_db")
            cursor.close()
            conn.close()

        # Now connect to created database
        conn = get_db_connection()
        if conn and conn.is_connected():
            cursor = conn.cursor()
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS leads (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    name VARCHAR(100) NOT NULL,
                    email VARCHAR(100) NOT NULL,
                    phone VARCHAR(20),
                    message TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
            conn.commit()
            cursor.close()
            conn.close()

            print("Database and table ready.")

    except Error as e:
        print(f"Database initialization failed: {e}")


# Initialize DB
init_db()


@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        name = request.form.get('name')
        email = request.form.get('email')
        phone = request.form.get('phone')
        message = request.form.get('message')

        if not name or not email:
            flash('Name and Email are required!', 'error')
            return redirect(url_for('index'))

        conn = get_db_connection()
        if conn and conn.is_connected():
            try:
                cursor = conn.cursor()
                query = "INSERT INTO leads (name, email, phone, message) VALUES (%s, %s, %s, %s)"
                cursor.execute(query, (name, email, phone, message))
                conn.commit()
                flash('Thank you! We have received your message.', 'success')
            except Error as e:
                flash(f'An error occurred: {e}', 'error')
            finally:
                cursor.close()
                conn.close()
        else:
            flash('Database connection failed.', 'error')

        return redirect(url_for('index'))

    return render_template('index.html')


@app.route('/leads')
def leads():
    leads_data = []
    conn = get_db_connection()

    if conn and conn.is_connected():
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("SELECT * FROM leads ORDER BY created_at DESC")
            leads_data = cursor.fetchall()
        except Error as e:
            flash(f"Error fetching leads: {e}", "error")
        finally:
            cursor.close()
            conn.close()
    else:
        flash("Could not connect to database.", "error")

    return render_template('leads.html', leads=leads_data)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
