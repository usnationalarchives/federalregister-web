class FolderDecorator < ApplicationDecorator
  decorates :folder
  delegate :count,
           :map, to: :folder
end
