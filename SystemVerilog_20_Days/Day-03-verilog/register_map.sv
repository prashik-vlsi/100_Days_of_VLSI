
module register_map;

    parameter address = 32;
    parameter value = 32;
    int first_key;

    // Declaration of associative array
    int reg_model [int];

    initial begin
        int user_address;

        // Initialize register map
        reg_model[1000] = 170;
        reg_model[2000] = 187;
        reg_model[3000] = 204;

        // Display stored values
        $display("Value at key 1000: %0d", reg_model[1000]);
        $display("Value at key 2000: %0d", reg_model[2000]);
        $display("Value at key 3000: %0d", reg_model[3000]);

        // Display number of entries
        $display("Total number of entries: %0d", reg_model.num());

        // Check whether a key exists
        user_address = 2000;
        if (reg_model.exists(user_address) != 0) begin
            $display("The entered key exists.");
            $display("Stored value: %0d", reg_model[user_address]);
        end
        else begin
            $display("The entered key does not exist.");
        end

        // traversing through the  list
        if(reg_model.first(first_key) != 0) begin
            $display("The first element in the array is: %0d", first_key);
        end

        //using the next key

        if(reg_model.next(first_key) != 0) begin
            $display("the next element is: %0d", first_key);
        end

        // iterating through all registers
        $display("DEBUG: Before foreach");

foreach (reg_model[key]) begin
    $display("Key: %0d, value: %0d", key, reg_model[key]);
end

$display("DEBUG: After foreach");


        //deleting the specififc keys
        reg_model.delete(1000); 

        if (reg_model.exists(1000) == 0) begin
        $display("Key 1000 was successfully deleted.");
        end
        else begin
            $display("Key 1000 still exists.");
            end

        //deleting the entire array

        reg_model.delete();

        $display("count is: %0d", reg_model.num());



    end


endmodule
