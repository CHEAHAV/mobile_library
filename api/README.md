# FastAPI Libraries project

## Overview

This is a FastAPI-based project designed for testing purposes. Follow the steps below to set up and run the application locally.

## Setup Instructions

1. **Clone the Project**
   - Clone the project from this repository:
     ```bash
     git clone https://gitlab.com/CHEAHAV/mobile_library.git
     ```

2. **Create .env File**
   - Create a `.env` file from `.env.example` and update the configuration:
     ```bash
     cp .env.example .env
     ```

3. **Create Virtual Environment**
   - Create a virtual environment:
     ```bash
     python -m venv venv
     ```

4. **Activate Virtual Environment**
   - Activate the virtual environment:
     ```bash
    venv/Stript/activate
     ```

5. ** install and update pip
    ```bash
    python -m pip install --upgrade pip
    ```
6. **Install Project Requirements**
   - Install the required dependencies:
     ```bash
     pip install -r requirements.txt
     ```

7. **Run the Project**
   - Run the application using Uvicorn:
     ```bash
     uvicorn main:app --reload


## Additional Information

- Ensure Python 3.8 or higher is installed on your system.
- Make sure the `.env` file contains the correct configurations to avoid runtime issues.
- For further assistance, please contact the project maintainers.

## If you want to use Docker you can follow the command
* open docker 

* use command in terminal

- wsl install

- docker compose up --build

- docker compose up

## web backend

http://127.0.0.1:8000/docs

## web database pgAmin

http://127.0.0.1:8080

gmail : check in docker-compose.yml, defaul : postgres@gmail.com
password : check in docker-compose.yml, defaul : 123123

## Click New server
## General
Name : db_libraries

## Connection
Host name/address : db
Maintenance database : postgres
Username : postgres
password : check in docker-compose.yml, defaul : 123123



