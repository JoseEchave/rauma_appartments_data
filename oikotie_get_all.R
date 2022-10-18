oikotie_php_session <- Sys.getenv("OIKOTIE_PHP_SESSION")
oikotie_user <- Sys.getenv("OIKOTIE_USER")
oikotie_awsalb <- Sys.getenv("OIKOTIE_AWSALB")
oikotie_awsalbcors <- Sys.getenv("OIKOTIE_AWSALBCORS")
oikotie_cuid <- Sys.getenv("OIKOTIE_CUID")
oikotie_token <- Sys.getenv("OIKOTIE_TOKEN")


cookies = c(
  'PHPSESSID' = oikotie_php_session,
  'user_id' = oikotie_user,
  'cardType' = '100',
  'AWSALB' = oikotie_awsalb,
  'AWSALBCORS' = oikotie_awsalbcors
)

headers = c(
  `authority` = 'asunnot.oikotie.fi',
  `accept` = 'application/json',
  `accept-language` = 'en-FI,en;q=0.9,es-ES;q=0.8,es;q=0.7,en-US;q=0.6',
  `dnt` = '1',
  `ota-cuid` = oikotie_cuid,
  `ota-loaded` = '1665913446',
  `ota-token` = oikotie_token,
  `referer` = 'https://asunnot.oikotie.fi/myytavat-asunnot?cardType=100&locations=%5B%5B326,6,%22Rauma%22%5D%5D',
  `sec-ch-ua` = '"Chromium";v="106", "Not;A=Brand";v="99"',
  `sec-ch-ua-mobile` = '?1',
  `sec-ch-ua-platform` = '"Android"',
  `sec-fetch-dest` = 'empty',
  `sec-fetch-mode` = 'cors',
  `sec-fetch-site` = 'same-origin',
  `user-agent` = 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Mobile Safari/537.36'
)

res <- httr::GET(url = 'https://asunnot.oikotie.fi/api/cards?cardType=100&limit=999&locations=%5B%5B326,6,%22Rauma%22%5D%5D&offset=0&sortBy=published_sort_desc',
                 httr::add_headers(.headers=headers),
                 httr::set_cookies(.cookies = cookies))
content_res <- httr::content(res)$cards

#Save results as JSON
exportJSON <- jsonlite::toJSON(content_res)
writeLines(exportJSON, glue::glue("data/appartments_oikotie_{Sys.Date()}.json"), useBytes=T)