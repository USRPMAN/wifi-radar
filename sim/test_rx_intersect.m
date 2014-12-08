function test_rx_intersect()

assert(rx_intersect([2.6,2.6], [2,2], [3,3], 0.5, 1, 30) == 1);
assert(rx_intersect([2,3], [2,2], [3,3], 0.5, 1, 30) == 0);

end
