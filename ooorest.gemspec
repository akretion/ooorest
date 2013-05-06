$:.push File.expand_path("../lib", __FILE__)

require "ooorest/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ooorest"
  s.version     = Ooorest::VERSION
  s.authors     = ["Raphael Valyi - www.akretion.com"]
  s.email       = %q{raphael.valyi@akretion.com}
  s.homepage    = %q{http://github.com/akretion/ooorest}
  s.summary     = "Who said ERP's cannot do REST? OpenERP can with Akretion!"
  s.description = "REST exposed OpenERP resources atop of Rails ActionPack. Can be mounted as a Rails Engine or used as a library in non Rails applications. Pluggable Authentication system."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "actionpack", ">= 3.1"
  s.add_dependency "ooor", ">= 1.9"
#  s.add_dependency 'kaminari', '~> 0.14'
end
