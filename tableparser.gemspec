
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tableparser/version"

Gem::Specification.new do |spec|
  spec.name          = "tableparser"
  spec.version       = Tableparser::VERSION
  spec.authors       = ["Zach Margolis"]
  spec.email         = ["zbmargolis@gmail.com"]

  spec.summary       = %q{Help parse table-like output}
  spec.description   = %q{Help parse table-like output such as from raw SQL}
  spec.homepage      = "https://github.com/zachmargolis/tableparser"
  spec.license       = "MIT"

  spec.metadata["yard.run"] = "yri"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.8.0"
  spec.add_development_dependency "yard", ">= 0.9.20"
end
