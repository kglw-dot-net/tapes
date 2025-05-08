Scalar.setup do |config|
  path = Rails.root.join('swagger/v1/swagger.yaml')

  if File.exist?(path)
    config.specification = File.read(path)
  end
end
