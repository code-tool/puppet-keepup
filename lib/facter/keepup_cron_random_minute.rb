require 'fileutils'

Facter.add('keepup_cron_random_minute') do
  setcode do
    directory_path = '/etc/puppetlabs/facter/facts.d'
    file_path = "#{directory_path}/keepup_cron_random_minute.txt"

    # Ensure the directory exists, recursively
    FileUtils.mkdir_p(directory_path)

    if File.exist?(file_path)
      # Read the existing random number from the file
      File.read(file_path).chomp
    else
      # Generate a new random number
      random_number = rand(1..59).to_s

      # Save the random number to the file
      File.open(file_path, 'w') do |file|
        file.write(random_number)
      end

      # Return the newly generated random number
      random_number
    end
  end
end
