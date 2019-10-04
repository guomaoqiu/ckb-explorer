class TypeScript < ApplicationRecord
  belongs_to :cell_output

  validates_presence_of :code_hash

  attribute :code_hash, :ckb_hash

  def to_node_type
    {
      args: args,
      code_hash: code_hash,
      hash_type: hash_type
    }
  end
end

# == Schema Information
#
# Table name: type_scripts
#
#  id             :bigint           not null, primary key
#  args           :string
#  code_hash      :binary
#  cell_output_id :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  hash_type      :string
#
# Indexes
#
#  index_type_scripts_on_cell_output_id  (cell_output_id)
#
