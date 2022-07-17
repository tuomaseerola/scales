# created for testing a shiny server (AWS)
# T. E. 17/7/2022
# For Fabian Moss's scales experiment
#
# shiny::runApp(".")
# 

library(psychTestR)
library(htmltools)
library(shiny) # optional

researcher_email <- 'tuomas.eerola@durham.ac.uk'
options <- test_options(title='Scales (beta 0.2)',
                        admin_password = 'meyer',
                        researcher_email = researcher_email,
                        display = display_options(left_margin = 1L,right_margin = 1L,content_border = "1px solid #f0eae4"))
landing_page <- div(
  id = "my_div",
  h3("Scales"),
  p("This experiment is about perception of similarity in music.", 
    "You will hear artificial sequences that we call ", tags$strong("tone clouds")," in this experiment.",
    "There are no right or wrong answers, but we will monitor the consistency of your responses,",
    "so do pay attention and attempt to follow instructions carefully."),
  h3("Consent"),
  p("Click next to indicate that you participate voluntarily (MORE ABOUT CONSENT)",
    strong("Click Next to continue."))
)

instructions_page <- div(
  id = "my_div2",
  h3("Your task"),
  p("You will hear three ", tags$strong("tone clouds"), "in succession. Your task is to",
    "spot the odd one out. In other words, you need to select which",
    tags$strong("tone cloud"), "sounds different from the two other sequences."),
    strong("Click Next to continue.")
)

sendhome_page <- div(
  id = "my_div",
  h3("Thank you"),
  p("This experiment is now done.", 
    "Your completition code is:"),
  code("120532"),
  p("Follow the link back to ",
    a("Prolific", href="https://www.prolific.co"))
)

#### Create tmp audio files -------------
print("create audio files")
source('create_pairwise_comparisons.R')
source('create_combined_audio.R')
#stimuli <- c("e1_e2.wav","e1_e3.wav","e2_e3.wav")
stim <- read.csv('stimuli.csv',header = TRUE)
p = create_pairwise_comparisons(filenames = stim$name,random_order = TRUE)
a = create_combined_audio(filenames = p$combinedfilenames)
stimuli <- p$created_files

delete_files <- code_block(function(state, ...) {
  print("delete tmp files")
  clean_cmd <-paste0('rm www/tmp_*')
  system(clean_cmd)
  })


#### audio rating task -------------

items <- purrr::map(stimuli, function(stimulus) {
  audio_NAFC_page(
    label = stimulus,
    prompt = paste0("How similar are these two tone clouds?  DEBUG:",stimulus),
    choices = as.character(1:6),
    labels = c("1 (very dissimilar)","2","3","4","5","6 (very similar)"),
    url = stimulus,
    save_answer = TRUE,
#   type = tools::file_ext(url),
#    show_controls = FALSE,
    wait = TRUE,
    loop = FALSE,
    show_controls = TRUE,
    button_style = "width:88px;height:65px; white-space: normal;",
#    btn_play_prompt = "Click here to play",
    autoplay = "autoplay",
    arrange_choices_vertically = FALSE,
    on_complete = function(answer, state, ...) {
      set_local(stimulus, as.numeric(answer), state)
    }
  )
})


save_res <- code_block(function(state, ...) {
  scores <- purrr::map_dbl(stimuli, get_local, state)
})

#### Compile separate pages ------------
make_test(opt=options,join(
  text_input_page(
    label="prolificID",
    prompt="Enter your prolific ID here",
    one_line = TRUE,
    save_answer = TRUE,
  ),
 #_ one_button_page(landing_page),
  get_basic_demographics(
    intro = basic_demographics_default_intro(),
    gender = FALSE,
    age = FALSE,
    occupation = FALSE,
    education = FALSE
  ),
# volume_calibration_page(),
# head_phone_check(),
#_  one_button_page(instructions_page),
  randomise_at_run_time('item',items), 
  save_res,
  elt_save_results_to_disk(complete = TRUE),
#  finish_test_and_give_code(researcher_email),
  delete_files,
  final_page(sendhome_page)
))
