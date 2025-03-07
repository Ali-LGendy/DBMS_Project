
# DBMS-Bash-Project - A Simple Bash-based Database Management System

DBMS-Bash-Project is a lightweight, command-line database management system (DBMS) built entirely using Bash scripting. It allows users to create, manage, and interact with databases and tables directly from the terminal. This project is designed for educational purposes and to demonstrate how a basic DBMS can be implemented using shell scripting.

## Features

- **Database Management**:
  - Create, list, and drop databases.
  - Connect to a specific database to perform table operations.
  
- **Table Management**:
  - Create, list, and drop tables.
  - Define table schemas with columns and data types (e.g., `int`, `string`).
  - Set primary keys for columns.

- **CRUD Operations**:
  - Insert, select, update, and delete records from tables.
  - Validate data types during insertion and updates.

- **User Interface**:
  - Interactive menus with color-coded prompts and messages.
  - Clear and intuitive command-line interface.

- **Logging**:
  - Log all operations (e.g., database creation, table modifications) to a log file for auditing.

- **Utilities**:
  - Input validation for names, data types, and values.
  - Random color generation for UI elements.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Ali-LGendy/DBMS_Project
   ```

2. Navigate to the project directory:
   ```bash
   cd DBMS_Project
   ```

3. Make the script executable:
   ```bash
   chmod +x dbms.sh
   ```

4. Run the DBMS:
   ```bash
   ./dbms.sh
   ```

## Usage

1. **Main Menu**:
   - Create, list, connect to, or drop databases.
   - Exit the DBMS.

2. **Database Operations**:
   - Once connected to a database, you can:
     - Create, list, and drop tables.
     - Perform CRUD operations (insert, select, update, delete) on tables.

3. **Logs**:
   - All operations are logged in `$HOME/DBMS/dbms.log`.

## File Structure

- `dbms.sh`: The main script that serves as the entry point for the DBMS.
- `settings.sh`: Configuration settings for the DBMS (e.g., root directory, colors, UI settings).
- `database.sh`: Contains functions for database operations (e.g., create, list, drop).
- `table.sh`: Contains functions for table operations (e.g., create, list, drop, CRUD).
- `ui.sh`: Handles the user interface components (e.g., banners, menus, prompts).
- `utils.sh`: Utility functions (e.g., input validation, logging, file checks).

## Example Workflow

1. **Create a Database**:
   - From the main menu, select option `1` to create a new database.
   - Enter a valid database name (e.g., `mydb`).

2. **Connect to the Database**:
   - Select option `3` from the main menu to connect to the database.
   - Choose the database you just created.

3. **Create a Table**:
   - From the database menu, select option `1` to create a table.
   - Define the table schema (e.g., `id:int`, `name:string`).

4. **Insert Data**:
   - Select option `4` to insert data into the table.
   - Enter values for each column.

5. **Query Data**:
   - Select option `5` to query data from the table.

6. **Drop a Table**:
   - Select option `3` to drop a table.

7. **Drop a Database**:
   - Return to the main menu and select option `4` to drop a database.

## Contributing

Contributions are welcome! If you'd like to contribute, please fork the repository and create a pull request with your changes. Ensure that your code follows the existing style and includes appropriate documentation.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

- This project was inspired by the need for a simple, educational tool to demonstrate database concepts using Bash scripting.
- Special thanks to the open-source community for providing resources and inspiration.

---

Enjoy using DBMS-Bash-Project! If you have any questions or feedback, feel free to open an issue on GitHub.
```
