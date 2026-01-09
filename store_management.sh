#!/bin/bash

# DATA FILE SETUP
DATA_FILE="medicines.csv"
SALES_FILE="sales.csv"

# Creating files if they don't exist
if [[ ! -f $DATA_FILE ]]; then
    echo "ID,Name,Price,Quantity,Expiry" > $DATA_FILE
fi

if [[ ! -f $SALES_FILE ]]; then
    echo "ID,Name,Quantity Sold,Total Price,Date" > $SALES_FILE
fi


show_menu() {
    echo -e "\nMedicine Store Management System"
    echo "1. Add New Medicine"
    echo "2. View Medicines"
    echo "3. Search Medicine"
    echo "4. Update Medicine"
    echo "5. Delete Medicine"
    echo "6. Sell Medicine"
    echo "7. Generate Sales Report"
    echo "8. Exit"
    echo "========================================"
}

add_medicine() {
    echo "Enter Medicine ID:"
    read id
    if grep -q "^$id," "$DATA_FILE"; then
        echo "Error: Medicine ID already exists!"
        return
    fi
    echo "Enter Medicine Name:"
    read name
    echo "Enter Price:"
    read price
    echo "Enter Quantity:"
    read quantity
    echo "Enter Expiry Date (YYYY-MM-DD):"
    read expiry
    
    echo "$id,$name,$price,$quantity,$expiry" >> $DATA_FILE
    echo "Success: Medicine added!"
}

view_medicines() {
    echo -e "\nCurrent Inventory"
    if [ $(wc -l < "$DATA_FILE") -le 1 ]; then
        echo "No medicines in stock."
    else
        column -t -s "," "$DATA_FILE"
    fi
}

search_medicine() {
    echo "Enter Medicine Name or ID to search:"
    read query
    echo -e "\n=== Search Results ==="
    grep -i "$query" "$DATA_FILE" | column -t -s ","
}

update_medicine() {
    echo "Enter Medicine ID to update:"
    read id
    if grep -q "^$id," "$DATA_FILE"; then
        # Remove old line
        grep -v "^$id," "$DATA_FILE" > temp.csv
        mv temp.csv "$DATA_FILE"
        echo "Enter NEW details below:"
        add_medicine
    else
        echo "Error: Medicine ID not found!"
    fi
}

delete_medicine() {
    echo "Enter Medicine ID to delete:"
    read id
    if grep -q "^$id," "$DATA_FILE"; then
        grep -v "^$id," "$DATA_FILE" > temp.csv
        mv temp.csv "$DATA_FILE"
        echo "Success: Medicine deleted!"
    else
        echo "Error: Medicine ID not found!"
    fi
}

sell_medicine() {
    echo "Enter Medicine ID to sell:"
    read id
    
    line=$(grep "^$id," "$DATA_FILE")
    
    if [[ -z "$line" ]]; then
        echo "Error: Medicine ID not found!"
        return
    fi

    # Extract details using comma
    name=$(echo "$line" | cut -d',' -f2)
    price=$(echo "$line" | cut -d',' -f3)
    current_qty=$(echo "$line" | cut -d',' -f4)

    echo "Medicine: $name | Price: $price | Available Stock: $current_qty"
    echo "Enter Quantity to sell:"
    read sell_qty

    if (( sell_qty > current_qty )); then
        echo "Error: Insufficient stock! Available: $current_qty"
    else
        
        new_qty=$((current_qty - sell_qty))
        total_price=$((sell_qty * price))
        current_date=$(date +%F)

        awk -F, -v id="$id" -v nq="$new_qty" 'BEGIN{OFS=","} $1==id {$4=nq} 1' "$DATA_FILE" > temp.csv && mv temp.csv "$DATA_FILE"
        
        
        echo "$id,$name,$sell_qty,$total_price,$current_date" >> "$SALES_FILE"
        
        echo "Success: Sold $sell_qty of $name for Total: $total_price"
    fi
}

generate_sales_report() {
    echo -e "\n= Sales Report ="
    if [ $(wc -l < "$SALES_FILE") -le 1 ]; then
        echo "No sales recorded yet."
    else
        column -t -s "," "$SALES_FILE"
    fi
}

while true; do
    show_menu
    echo -n "Enter your choice: "
    read choice
    case $choice in
        1) add_medicine ;;
        2) view_medicines ;;
        3) search_medicine ;;
        4) update_medicine ;;
        5) delete_medicine ;;
        6) sell_medicine ;;
        7) generate_sales_report ;;
        8) echo "Exiting..."; exit ;;
        *) echo "Invalid choice! Please try again." ;;
    esac
done
