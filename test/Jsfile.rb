assets_path "assets/javascript"

group :vendor, :assets_path => "assets/js"  do
  js "jquery"
  js "backbone", "1.2"
end

group :lib do
  js "jquery"
  js "backbone", "1.2"
end