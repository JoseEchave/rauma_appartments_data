require(httr)

etuovi_token <-  Sys.getenv("ETUOVI_TOKEN")
etuovi_uuidc <- Sys.getenv("ETUOVI_UUIDC")
etuovi_session <- Sys.getenv("ETUOVI_SESSION")
etuovi_bsid <- Sys.getenv("ETUOVI_BSID")
etuovi_init <- Sys.getenv("ETUOVI_INIT")

#Cookies
cookies = c(
  'XSRF-TOKEN' = etuovi_token,
  'uuidc' = etuovi_uuidc,
  'SESSION' = etuovi_session,
  'sammio-bsid' = etuovi_bsid,
  'sammio-init-time' = etuovi_init
)

#Header
headers = c(
  `authority` = 'www.etuovi.com',
  `accept` = 'application/json',
  `accept-language` = 'en-FI,en;q=0.9,es-ES;q=0.8,es;q=0.7,en-US;q=0.6',
  `content-type` = 'application/json',
  `dnt` = '1',
  `origin` = 'https://www.etuovi.com',
  `referer` = 'https://www.etuovi.com/myytavat-asunnot?haku=M1902927603',
  `sec-ch-ua` = '"Chromium";v="106", "Not;A=Brand";v="99"',
  `sec-ch-ua-mobile` = '?1',
  `sec-ch-ua-platform` = '"Android"',
  `sec-fetch-dest` = 'empty',
  `sec-fetch-mode` = 'cors',
  `sec-fetch-site` = 'same-origin',
  `user-agent` = 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Mobile Safari/537.36',
  `x-xsrf-token` = etuovi_token
)

#API calls
page_num <- 1

etuovi_api_call_rauma <- function(page_num){
  data = glue::glue('{"locationSearchCriteria":{"unclassifiedLocationTerms":[],"classifiedLocationTerms":[{"type":"POST_CODE","index":0,"classified":true,"code":"26100","shortName":"26100","parentCountryCode":"FI","fullName":"26100 RAUMA"}]},"pagination":{"firstResult":0,"maxResults":50,"page":<<page_num>>,"sortingOrder":{"property":"PUBLISHED_OR_UPDATED_AT","direction":"DESC"}},"priceMin":null,"priceMax":null,"sizeMin":null,"sizeMax":null,"sellerType":"ALL","bidType":"ALL","publishingTimeSearchCriteria":"ANY_DAY","showingSearchCriteria":{},"propertyType":"RESIDENTIAL","freeTextSearch":"","plotAreaMin":null,"plotAreaMax":null,"yearMin":null,"yearMax":null,"priceSquareMeterMin":null,"priceSquareMeterMax":null,"maintenanceChargeMin":null,"maintenanceChargeMax":null,"newBuildingSearchCriteria":"ALL_PROPERTIES"}',
                    .open = "<<",
                    .close = ">>")
  
  res <- httr::POST(url = 'https://www.etuovi.com/api/v2/announcements/search/listpage',
                    httr::add_headers(.headers=headers),
                    httr::set_cookies(.cookies = cookies),
                    body = data)
  print(res$status_code)
  httr::content(res)
}



res_content <- etuovi_api_call_rauma(page_num)
res_appartments <- res_content$announcements

count_results <- res_content$countOfAllResults
num_pages <- ceiling(count_results/50)

if (count_results > 50){
  while (page_num != num_pages){
    page_num <- page_num + 1
    res_appartments <- append(res_appartments,etuovi_api_call_rauma(page_num)$announcements)
    Sys.sleep(3)
  }
  print("done")
} else{
  print("done")
}

#Save results as JSON
exportJSON <- jsonlite::toJSON(res_appartments)
writeLines(exportJSON, glue::glue("data/appartments_etuovi_{Sys.Date()}.json"), useBytes=T)


