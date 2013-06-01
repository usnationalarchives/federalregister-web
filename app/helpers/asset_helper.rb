module AssetHelper
  def my_asset_path(asset_name)
    if Rails.env.development?
      "/my#{asset_path(asset_name)}"
    else
      asset_path(asset_name)
    end
  end
end
