module queue;
    int q [$];
    initial begin
        q.push_back(1); q.push_back(2); q.push_front(0); q.push_back(3);
        $display("size=%0d", q.size());

        foreach (q[i])
        $display("q[%0d]=%0d", i , q[i]);

        /* insertion at place index 1 */

        q.insert(1, 99);
        q.insert(2, 96);
        foreach (q[i]) $display("q[%0d]=%0d", i, q[i]);

        /* deleting the one element from the index */
        q.delete(2);
        foreach (q[i]) $display("q[%0d]=%0d", i, q[i]);

        /* deleting the entire queue */
        q.delete();
        foreach (q[i]) $display("q[%0d]=%0d", i, q[i]);


        $display("the size of the queue is =%0d", q.size());


    end
endmodule