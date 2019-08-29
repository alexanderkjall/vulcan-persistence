module Api::V1
  class SimpleCheckSerializer < ActiveModel::Serializer
    attributes :id, :target, :status, :checktype_name

  def checktype_name
    object.checktype.name
  end
  end
end
