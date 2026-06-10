class PostDecorator < Tramway::BaseDecorator
  delegate_attributes :content, :user_id, :created_at, :updated_at

  def title
    "Post ##{object.id}"
  end

  def self.index_attributes
    %i[id content user_id created_at]
  end

  def show_attributes
    %i[id content user_id created_at updated_at]
  end
end
