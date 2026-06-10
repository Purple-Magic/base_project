class PostForm < Tramway::BaseForm
  properties :content, :user, :published

  fields(
    content: {
      type: :rich_text_area
    },
    user: {
      type: :select,
      collection: User.all.map { ["#{it.first_name} #{it.last_name}", it.id] }
    },
    published: :check_box
  )

  def user=(value)
    object.user = User.find value
  end

  def published
  end
end
