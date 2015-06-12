Gem::Specification.new do |spec|
  spec.name          = "lita-cmd"
  spec.version       = "0.2.0"
  spec.authors       = ["Devon Finninger"]
  spec.email         = ["devon.finninger@peopleadmin.com"]
  spec.description   = "Run commands from Lita"
  spec.summary       = "Run commands from Lita"
  spec.homepage      = "https://github.com/dfinninger/lita-cmd"
  spec.license       = "MIT"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.3"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
end
