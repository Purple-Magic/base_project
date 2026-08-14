class PostForm < Tramway::BaseForm
  properties :content, :user

  fields(
    content: {
      type: :text_area
    },
    user: {
      type: :select,
      collection: User.all.map { ["#{it.first_name} #{it.last_name}", it.id] }
    }
  )

  def user=(value)
    object.user = value.present? ? User.find(value) : nil
  end
end
