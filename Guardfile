group :units do
  guard 'minitest', all_after_pass: true, spec_paths: ["spec/unit"] do
    watch(%r{^spec/unit/.+_spec\.rb})
    watch(%r{^lib/(.+)\.rb})     { |m| "spec/unit/#{m[1]}_spec.rb" }
    watch("spec/spec_helper.rb") { "spec" }
  end
end
