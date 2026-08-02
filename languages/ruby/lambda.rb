mul_ver_one = Proc.new do |aa, bb|
    next (aa * bb)
end
# or mul_ver_one = Proc.new do |aa, bb| (aa * bb) end
puts("mul_ver_one.call(7, 5): #{mul_ver_one.call(7, 5)}")

mul_ver_two = proc do |aa, bb|
    next (aa * bb)
end
# or mul_ver_two = proc do |aa, bb| (aa * bb) end
puts("mul_ver_two.call(7, 5): #{mul_ver_two.call(7, 5)}")

mul_ver_three = lambda do |aa, bb|
    next (aa * bb)
end
# or mul_ver_three = lambda do |aa, bb| (aa * bb) end
puts("mul_ver_three.call(7, 5): #{mul_ver_three.call(7, 5)}")

mul_ver_four = ->(aa, bb) do
    next (aa * bb)
end
# or mul_ver_four = ->(aa, bb) do (aa * bb) end
puts("mul_ver_four.call(7, 5): #{mul_ver_four.call(7, 5)}")
