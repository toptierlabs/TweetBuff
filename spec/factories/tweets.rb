Factory.define :tweet do |t|
  t.title "Title"
  t.body (0...20).map{65.+(rand(25)).chr}.join
end