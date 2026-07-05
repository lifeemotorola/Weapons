#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
================================================
Matrix Master - A Beautiful Matrix Tool for Termux
================================================
Author: Emmanuel Suah
Version: 1.0.0

A command-line tool to perform various advanced matrix operations.
Designed with a clean and colorful interface for terminal environments like Termux.
"""

import numpy as np
import os
import sys

# --- ANSI Color Codes for Beautiful Output ---
class C:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    END = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

# --- Helper Functions ---

def clear_screen():
    """Clears the terminal screen."""
    os.system('cls' if os.name == 'nt' else 'clear')

def wait_for_enter():
    """Pauses the script and waits for the user to press Enter."""
    input(f"\n{C.CYAN}Press Enter to return to the main menu...{C.END}")

def print_banner():
    """Prints the main banner of the tool."""
    print(C.BOLD + C.GREEN)
    print("╔════════════════════════════════════════════════════════════╗")
    print("║                                                            ║")
    print("║   ███╗   ███╗ █████╗ ████████╗██████╗ ██╗  ██╗██╗   ██╗     ║")
    print("║   ████╗ ████║██╔══██╗╚══██╔══╝██╔══██╗╚██╗██╔╝╚██╗ ██╔╝     ║")
    print("║   ██╔████╔██║███████║   ██║   ██████╔╝ ╚███╔╝  ╚████╔╝      ║")
    print("║   ██║╚██╔╝██║██╔══██║   ██║   ██╔══██╗ ██╔██╗   ╚██╔╝       ║")
    print("║   ██║ ╚═╝ ██║██║  ██║   ██║   ██║  ██║██╔╝ ██╗   ██║        ║")
    print("║   ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝        ║")
    print("║                      - for Termux -                        ║")
    print("║                                                            ║")
    print("╚════════════════════════════════════════════════════════════╝")
    print(C.END)

def print_matrix(matrix, title="Matrix"):
    """Prints a NumPy matrix with a beautiful border."""
    print(f"\n{C.BOLD}{C.HEADER}--- {title} ---{C.END}")
    if matrix.ndim == 0: # Handle scalar results like determinant
        print(f"  {C.GREEN}{matrix}{C.END}")
        return
        
    # Find the maximum width needed for any number
    max_len = max(len(f"{x:.4f}".rstrip('0').rstrip('.')) for x in np.nditer(matrix))
    
    # Print top border
    print(C.BLUE + "┌" + "─" * (matrix.shape[1] * (max_len + 3) + 1) + "┐" + C.END)

    for row in matrix:
        line = " │ "
        for item in row:
            # Format each number to a fixed width
            line += f"{item:<{max_len}.4f}".rstrip('0').rstrip('.') + " │ "
        print(C.BLUE + "│" + C.END + line.rstrip())
        
    # Print bottom border
    print(C.BLUE + "└" + "─" * (matrix.shape[1] * (max_len + 3) + 1) + "┘" + C.END)

def get_matrix(name="Matrix"):
    """Prompts the user to enter a matrix and returns it as a NumPy array."""
    print(f"\n{C.CYAN}Enter details for {C.BOLD}{name}{C.END}{C.CYAN}:{C.END}")
    while True:
        try:
            rows = int(input(f"  Enter number of rows: {C.GREEN}"))
            cols = int(input(f"  Enter number of columns: {C.GREEN}"))
            print(C.END, end="")
            if rows > 0 and cols > 0:
                break
            print(f"{C.FAIL}Rows and columns must be positive integers.{C.END}")
        except ValueError:
            print(f"{C.FAIL}Invalid input. Please enter integers.{C.END}")

    matrix_data = []
    print(f"{C.CYAN}Enter matrix elements row by row (space-separated numbers):{C.END}")
    for i in range(rows):
        while True:
            row_str = input(f"  Row {i+1}: {C.GREEN}")
            print(C.END, end="")
            try:
                row_list = [float(x) for x in row_str.split()]
                if len(row_list) == cols:
                    matrix_data.append(row_list)
                    break
                else:
                    print(f"{C.FAIL}Error: Please enter exactly {cols} numbers for this row.{C.END}")
            except ValueError:
                print(f"{C.FAIL}Invalid input. Please enter space-separated numbers only.{C.END}")
    
    return np.array(matrix_data)

# --- Matrix Operation Functions ---

def op_add_subtract(operation='add'):
    """Performs matrix addition or subtraction."""
    op_symbol = '+' if operation == 'add' else '-'
    op_name = 'Addition' if operation == 'add' else 'Subtraction'
    
    print(f"\n{C.HEADER}--- Matrix {op_name} (A {op_symbol} B) ---{C.END}")
    A = get_matrix("Matrix A")
    B = get_matrix("Matrix B")

    if A.shape != B.shape:
        print(f"\n{C.FAIL}Error: Matrices must have the same dimensions for {op_name.lower()}.{C.END}")
        return

    result = np.add(A, B) if operation == 'add' else np.subtract(A, B)
    print_matrix(A, "Matrix A")
    print_matrix(B, "Matrix B")
    print_matrix(result, f"Result (A {op_symbol} B)")

def op_scalar_multiply():
    """Performs scalar multiplication."""
    print(f"\n{C.HEADER}--- Scalar Multiplication (c * A) ---{C.END}")
    A = get_matrix("Matrix A")
    while True:
        try:
            scalar = float(input(f"{C.CYAN}  Enter the scalar value (c): {C.GREEN}"))
            print(C.END, end="")
            break
        except ValueError:
            print(f"{C.FAIL}Invalid input. Please enter a number.{C.END}")

    result = A * scalar
    print_matrix(A, "Matrix A")
    print(f"\n{C.BOLD}{C.HEADER}--- Scalar (c) ---{C.END}\n  {C.GREEN}{scalar}{C.END}")
    print_matrix(result, "Result (c * A)")
    
def op_matrix_multiply():
    """Performs matrix multiplication."""
    print(f"\n{C.HEADER}--- Matrix Multiplication (A * B) ---{C.END}")
    A = get_matrix("Matrix A")
    B = get_matrix("Matrix B")

    if A.shape[1] != B.shape[0]:
        print(f"\n{C.FAIL}Error: The number of columns in Matrix A ({A.shape[1]}) must equal the number of rows in Matrix B ({B.shape[0]}).{C.END}")
        return

    result = np.dot(A, B)
    print_matrix(A, "Matrix A")
    print_matrix(B, "Matrix B")
    print_matrix(result, "Result (A * B)")
    
def op_transpose():
    """Calculates the transpose of a matrix."""
    print(f"\n{C.HEADER}--- Matrix Transpose ---{C.END}")
    A = get_matrix("Matrix A")
    result = A.T
    print_matrix(A, "Original Matrix")
    print_matrix(result, "Transpose")

def op_determinant():
    """Calculates the determinant of a square matrix."""
    print(f"\n{C.HEADER}--- Matrix Determinant ---{C.END}")
    A = get_matrix("Matrix A")

    if A.shape[0] != A.shape[1]:
        print(f"\n{C.FAIL}Error: Determinant can only be calculated for square matrices.{C.END}")
        return

    try:
        det = np.linalg.det(A)
        print_matrix(A, "Matrix")
        print(f"\n{C.BOLD}{C.HEADER}--- Determinant ---{C.END}\n  {C.GREEN}{det:.6f}{C.END}")
    except np.linalg.LinAlgError as e:
        print(f"\n{C.FAIL}An unexpected linear algebra error occurred: {e}{C.END}")
        
def op_inverse():
    """Calculates the inverse of a square matrix."""
    print(f"\n{C.HEADER}--- Matrix Inverse ---{C.END}")
    A = get_matrix("Matrix A")

    if A.shape[0] != A.shape[1]:
        print(f"\n{C.FAIL}Error: Inverse can only be calculated for square matrices.{C.END}")
        return

    try:
        inv = np.linalg.inv(A)
        print_matrix(A, "Original Matrix")
        print_matrix(inv, "Inverse Matrix")
    except np.linalg.LinAlgError:
        print(f"\n{C.FAIL}Error: This matrix is singular (non-invertible) as its determinant is zero.{C.END}")

def op_rank():
    """Calculates the rank of a matrix."""
    print(f"\n{C.HEADER}--- Matrix Rank ---{C.END}")
    A = get_matrix("Matrix A")
    rank = np.linalg.matrix_rank(A)
    print_matrix(A, "Matrix")
    print(f"\n{C.BOLD}{C.HEADER}--- Rank ---{C.END}\n  {C.GREEN}{rank}{C.END}")
    
def op_eigen():
    """Calculates eigenvalues and eigenvectors of a square matrix."""
    print(f"\n{C.HEADER}--- Eigenvalues & Eigenvectors ---{C.END}")
    A = get_matrix("Matrix A")

    if A.shape[0] != A.shape[1]:
        print(f"\n{C.FAIL}Error: Eigenvalues/vectors can only be calculated for square matrices.{C.END}")
        return
        
    try:
        eigenvalues, eigenvectors = np.linalg.eig(A)
        print_matrix(A, "Matrix A")
        
        print(f"\n{C.BOLD}{C.HEADER}--- Eigenvalues (λ) ---{C.END}")
        print(f"  {C.GREEN}{', '.join([f'{v:.4f}' for v in eigenvalues])}{C.END}")
        
        print_matrix(eigenvectors, "Eigenvectors (columns)")
        print(f"{C.CYAN}Note: Each column in the Eigenvectors matrix corresponds to an eigenvalue.{C.END}")
        
    except np.linalg.LinAlgError as e:
        print(f"\n{C.FAIL}Eigen decomposition failed. The algorithm did not converge. Error: {e}{C.END}")

# --- Main Program Loop ---

def main():
    """The main function to run the menu loop."""
    menu_options = {
        '1': ('Add Matrices (A + B)', lambda: op_add_subtract('add')),
        '2': ('Subtract Matrices (A - B)', lambda: op_add_subtract('subtract')),
        '3': ('Scalar Multiplication (c * A)', op_scalar_multiply),
        '4': ('Matrix Multiplication (A * B)', op_matrix_multiply),
        '5': ('Transpose a Matrix', op_transpose),
        '6': ('Calculate Determinant', op_determinant),
        '7': ('Calculate Inverse', op_inverse),
        '8': ('Calculate Rank', op_rank),
        '9': ('Eigenvalues & Eigenvectors', op_eigen),
        '0': ('Exit', lambda: sys.exit(f"{C.GREEN}Goodbye!{C.END}")),
    }

    while True:
        clear_screen()
        print_banner()
        print(f"{C.BOLD}{C.UNDERLINE}Choose an operation:{C.END}\n")
        
        for key, (desc, _) in menu_options.items():
            print(f"  {C.WARNING}[{key}]{C.END} {C.CYAN}{desc}{C.END}")
        
        choice = input(f"\n{C.BOLD}Enter your choice: {C.GREEN}")
        print(C.END)

        if choice in menu_options:
            clear_screen()
            print_banner()
            # Execute the chosen function
            menu_options[choice][1]()
            wait_for_enter()
        else:
            print(f"{C.FAIL}Invalid choice. Please try again.{C.END}")
            wait_for_enter()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n\n{C.WARNING}Program interrupted by user. Exiting.{C.END}")
        sys.exit(0)
