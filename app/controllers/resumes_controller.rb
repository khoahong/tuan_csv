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
      processed_file = proceed_csv(file.path)
   
      @resume = Resume.new(resume_params)
      @resume.attachment = processed_file
      @resume.name = file.original_filename

      if @resume.save
         redirect_to resumes_path, notice: "Successfully uploaded."
      else
         render "new"
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
   
   def proceed_csv(csv_file_path)
      begin
         table = CSV.read(csv_file_path, col_sep: ';')
      rescue
         table = CSV.read(csv_file_path, col_sep: ',')
      end
      
      file = CSV.open(csv_file_path, "w")
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