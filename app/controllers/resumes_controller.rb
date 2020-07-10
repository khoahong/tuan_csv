require 'set'
require 'csv'

class ResumesController < ApplicationController
   def index
      @resumes = Resume.all
   end
   
   def new
      @resume = Resume.new
   end
   
   def create
      # contents = @resume.attachment.read
      # puts File.dirname(@resume.attachment.file.path)
      file = params[:resume]['attachment']
      
      if (File.extname(file.path) != '.csv')
         render text: "Not a .csv file!"
      else
         processed_file = proceed_csv(file.path, file.original_filename)
         @resume = Resume.new(resume_params)
         @resume.attachment = processed_file
         @resume.name = file.original_filename
   
         if @resume.save
            redirect_to resumes_path, notice: "Successfully uploaded."
         else
            render "new"
         end
      end
   end
   
   def destroy
      @resume = Resume.find(params[:id])
      @resume.destroy
      redirect_to resumes_path, notice:  "Successfully deleted."
   end
   
   private

   def resume_params
      params.require(:resume).permit(:name, :attachment)
   end
   
   def proceed_csv(csv_file_path, original_filename)
      begin
         table = CSV.read(csv_file_path, col_sep: ';')
      rescue
         table = CSV.read(csv_file_path, col_sep: ',')
      end
      
      new_file_name = original_filename.split('.csv').first + "_loc" + File.extname(original_filename)
      new_file_path = File.dirname(csv_file_path) + '/' + new_file_name

      file = CSV.open(new_file_path, "w")
      tmp_hash_c = Set.new

      table.each do |row|
         tmp_hash_c.add(row.last)
      end
         
      table.each do |row|
         if (!row.first.nil? && !tmp_hash_c.include?(row.first))
            file << row
         end
      end

      file.close

      file
   end
end