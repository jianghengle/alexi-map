class RenameFieldOnDownload < ActiveRecord::Migration[5.0]
  def change
  	rename_column :downloads, :type, :typ
  end
end
