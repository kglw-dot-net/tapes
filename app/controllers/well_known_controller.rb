# Serves /.well-known files used by the native apps for universal links.
# Inherits from ActionController::Base to skip ApplicationController's layout queries.
class WellKnownController < ActionController::Base
  def apple_app_site_association
    expires_in 3.days, public: true
    render json: {
      applinks: {
        details: [
          {
            appIDs: [ "QHJAD8Z2WL.gizz.tapes.GizzTapes" ],
            components: [
              { "/" => "/api/*", "exclude" => true },
              { "/" => "/swagger/*", "exclude" => true },
              { "/" => "/feed.xml", "exclude" => true },
              { "/" => "*" }
            ]
          }
        ]
      }
    }
  end

  def assetlinks
    expires_in 3.days, public: true
    fingerprints = [
      # Release keys (Play Store and other stores)
      "CD:9A:8E:7D:FA:19:D4:C9:A2:3E:8A:46:51:3D:5B:71:53:E3:A0:72:8D:E6:AF:EF:A2:83:7B:85:36:B0:1E:51",
      "0A:32:1C:76:61:9C:8E:E5:CB:52:CD:42:9E:87:14:84:18:5E:7E:7C:95:B5:F3:4E:33:AA:16:E3:4C:2E:7F:13",
      "56:0A:45:1D:AB:45:50:D1:FE:82:46:EF:96:7D:47:88:D2:7E:46:84:36:BC:63:AD:23:C7:C6:96:5C:E0:24:C0",
      # Debug keystore
      "7A:23:EB:CC:E8:A6:E1:B7:23:5D:28:37:6E:02:DC:97:6E:BE:3B:D5:E5:63:58:AA:88:82:EC:D9:19:30:46:19"
    ]

    # gizz.tapes.full: Play Store build, gizz.tapes.foss: F-Droid build
    render json: %w[gizz.tapes.full gizz.tapes.foss].map { |package_name|
      {
        relation: [ "delegate_permission/common.handle_all_urls" ],
        target: {
          namespace: "android_app",
          package_name: package_name,
          sha256_cert_fingerprints: fingerprints
        }
      }
    }
  end
end
