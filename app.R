# created for testing a shiny server (AWS)

library(psychTestR)
library(htmltools)
library(shiny) # optional

researcher_email <- 'tuomas.eerola@durham.ac.uk'
options <- test_options(title='Scales (beta 0.1)',
                        admin_password = 'meyer',
                        researcher_email = researcher_email)

landing_page <- div(
  id = "my_div",
  h3("Scales"),
  p("This experiment is about scales.", 
    "You will hear three sequences of sounds in succession. Your task is",
    "spot the odd one out. In other words, indicate which",
    "tone clouds sounds different compared with the two others. (BLAH BLAH....)"),
  h3("Consent"),
  p("Click next to indicate that you participate voluntarily (MORE ABOUT CONSENT)",
    strong("Click Next to continue."))
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


stimuli <- c("ex1.wav")

items <- purrr::map(stimuli, function(stimulus) {
  audio_NAFC_page(
    label = stimulus,
    prompt = paste0("Which one is the odd one out (", stimulus, ")?"),
    choices = as.character(1:3),
#    choices = c("Sound 1","Sound 2","Sound 3"),
    url = stimulus,
    show_controls = FALSE,
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

#### Compile separate pages
make_test(opt=options,join(
  text_input_page(
    label="pe",
    prompt="Enter your prolific ID here",
    one_line = TRUE,
    save_answer = TRUE,
  ),
  one_button_page(landing_page),
  get_basic_demographics(
    intro = basic_demographics_default_intro(),
    gender = FALSE,
    age = FALSE,
    occupation = FALSE,
    education = FALSE
  ),
  randomise_at_run_time('item',items), 
  save_res,
  elt_save_results_to_disk(complete = TRUE),
#  finish_test_and_give_code(researcher_email),
  final_page(sendhome_page)
))

