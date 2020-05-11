require 'xcodeproj'

projectName = ARGV[0]
lan = ARGV[1]
extension = ARGV[2]
project_path = "../#{projectName}"
project_file_path = "../#{projectName}/#{projectName}.xcodeproj"
main_file_path = "../#{projectName}/#{projectName}/Source" 
extension_suffix = lan == "oc" ? "Category" : "Extension"
extension_file_path = "../#{projectName}/#{projectName}/#{extension_suffix}" 
project = Xcodeproj::Project.open(project_file_path)

def add_group(relative_path, project, group)
    path = File.expand_path(relative_path)
    parent_group_reference = project.main_group[group].new_group(File.basename(path))
#    puts group + " 文件夹 " + path

    Dir.glob(path + "/*") do |item|
        if File.directory?(item)
            parent = File.basename(File.dirname(item))
            add_group(item, project, group + "/" + parent)
        else
            parent = File.basename(File.dirname(item))
#            puts group + "/" + parent + " 文件 " + item
            file = project.main_group[group + "/" + parent].new_reference(item)
            project.targets.first.add_file_references([file])
        end
    end
end

def add_specs(project_relative_path, project, group)
    project_path = File.expand_path(project_relative_path)
    Dir.glob(project_path + "/*.podspec") do |item|
        file = project.main_group[group].new_reference(item)
        file.set_explicit_file_type('text.script.ruby')
        file.set_last_known_file_type('text.script.ruby')
    end
end

if extension == "1"
    add_group(main_file_path, project, projectName)
    add_group(extension_file_path, project, projectName)
end
add_specs(project_path, project, projectName)

project.save
