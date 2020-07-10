require 'csv'
require 'set'

table = CSV.read(ARGV[0])
file = CSV.open(ARGV[1], "w")
tmp_hash_c = Set.new


table.each do |row|
	tmp_hash_c.add(row.last)
end
	
table.each do |row|
	if (!row.first.nil? && !tmp_hash_c.include?(row.first))
		file << row
	end
end
