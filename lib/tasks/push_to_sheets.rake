require "google_drive"

namespace :stats do
  desc "Update the Google sheet with trader stats"
  task update_traders_sheet: :environment do
    client_secret_path = "config/google-service-config.json"
    google = GoogleDrive::Session.from_service_account_key(client_secret_path)

    sheet = google.spreadsheet_by_key("").worksheets[0]

    sheet.rows.each_with_index do |_row, index|
    end
    sheet.save
  end
end
