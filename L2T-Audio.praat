
# Code dependencies:
# include session_parameters.praat
# include L2T-Utilities.praat



procedure audio_error: .directory$
                   ... .participant_number$
  printline
  printline
  printline <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>>
  printline
  printline ERROR :: No audio file was loaded
  printline
  printline Make sure the following directory exists on your computer:
  printline '.directory$'
  printline 
  printline Also, make sure that directory contains an audio
        ... file for participant '.participant_number$'.
  printline
  printline <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>> <<<>>>
  printline
  printline 
endproc




procedure audio_directory: .workstation$
                       ... .experimental_task$
                       ... .testwave$
  # Set the main trunk of the [.directory$] of the audio files for the current [.workstation$].
  @workstations
  if .workstation$ == workstations.waisman$
    # Waisman Lab (UW) setup...
    .directory$ = "L:/DataAnalysis"
  elif .workstation$ == workstations.shevlin$
    # Shevlin Hall (UMN) setup...
    .directory$ = "//l2t.cla.umn.edu/tier2/DataAnalysis"
  elif .workstation$ == workstations.mac_rdc$
    .directory$ = "I:/DataAnalysis"
  elif .workstation$ == workstations.mac_vpn$
    .directory$ = "/Volumes/tier2onUSB/DataAnalysis"
  elif .workstation$ == workstations.beckman$
    # Mary's set-up, where audio is accessed locally...
    .directory$ = "/LearningToTalk/Tier2/DataAnalysis"
  elif .workstation$ == workstations.reidy_vpn$
    # Pat's setup where the audio is accessed through a VPN connection...
    .directory$ = "/Volumes/tier2/DataAnalysis"
  elif .workstation$ == workstations.reidy_split$
    # Pat's setup where the audio is accessed locally, but the other data are accessed through a VPN connection...
    .directory$ = "/Volumes/liveoak/LearningToTalk"
  elif .workstation$ == workstations.hannele$
    .directory$ = "Z:/DataAnalysis"
  elif .workstation$ == workstations.rose_vpn$
    .directory$ = "/Volumes/tier2/DataAnalysis"
  elif .workstation$ == workstations.rose_split$
    .directory$ = "/Volumes/tier2onUSB/DataAnalysis"
  elif .workstation$ == workstations.allie_laptop$
    .directory$ = "/Volumes/tier2/DataAnalysis"
  elif .workstation$ == workstations.other$
    # Some previously un-encountered setup...
    .directory$ = ""
  endif
  # Complete the [.directory$] path only if the [.workstation$] has been previously encountered.
  if .workstation$ != workstations.other$
    .directory$ = .directory$ + "/" +
              ... .experimental_task$ + "/" +
              ... .testwave$
    # The organization of the recordings on Pat's external drive (i.e., when the [.workstation$] is [workstations.reidy_split$]) differs from how these files are organized for every other workstation.  So, [.directory$] must be completed differently for different workstations.
    if .workstation$ == workstations.reidy_split$
      .directory$ = .directory$ + "/" + "Audio"
    else
      .directory$ = .directory$ + "/" + "Recordings"
    endif
  # If the [.workstation$] has not been encountered before, then the [.directory$] and [.pattern$] for finding audio files are both set to empty strings, since the structure of that workstation's filesystem cannot be guessed and it should be ensured that no audio file is loaded when the workstation is novel.
  else
    .directory$ = ""
  endif
endproc




procedure audio_extension
  .extension$ = if (macintosh or unix) then ".WAV" else ".wav" endif
endproc




procedure audio_pattern: .directory$
                     ... .experimental_task$
                     ... .participant_number$
                     ... .extension$
  if .directory$ != ""
    .pattern$ = .directory$ + "/" + 
            ... .experimental_task$ + "_" + .participant_number$ + "*" + 
            ... .extension$
  else
    .pattern$ = ""
  endif
endproc




procedure audio_filename: .pattern$
  @filename_from_pattern: .pattern$, "audio file"
  .filename$ = filename_from_pattern.filename$
endproc




procedure audio_filepaths: .directory$
                       ... .filename$
  # If neither the [.directory$] nor the [.filename$] is an empty string, then
  # set the [.read_from$] and [.write_to$] directories by concatenating the
  # directory and filename.
  if (.directory$ <> "") & (.filename$ <> "")
    .read_from$ = .directory$ + "/" + .filename$
    .write_to$  = .directory$ + "/" + .filename$
  else
    .read_from$ = ""
    .write_to$  = ""
  endif
endproc




procedure load_audio: .filepath$
  if .filepath$ <> ""
    # Parse the [.filepath$]
    @parse_filepath: .filepath$
    # Print a message.
    printline Loading audio file 'parse_filepath.filename$' from
          ... 'parse_filepath.directory$'
    # Extract the participant's ID from the audio filename.
    @participant: .filepath$, session_parameters.participant_number$
    # Load the audio file as a Praat Sound object.
    Read from file... '.filepath$'
    Rename... 'participant.id$'_Audio
    # Store the name of the Praat Sound Object.
    .praat_obj$ = selected$()    
  else
    .praat_obj$ = ""
  endif
endproc




procedure audio
  # Import constants from the [session_parameters] namespace. 
  .workstation$        = session_parameters.workstation$
  .experimental_task$  = session_parameters.experimental_task$
  .testwave$           = session_parameters.testwave$
  .participant_number$ = session_parameters.participant_number$
  
  # Set the [.directory$] of the audio recordings.
  @audio_directory: .workstation$, .experimental_task$, .testwave$
  .directory$ = audio_directory.directory$
  
  # Set the [.extension$] of the audio recordings.
  @audio_extension
  .extension$ = audio_extension.extension$
  
  # Set the [.pattern$] used to find audio recordings.
  @audio_pattern: .directory$, 
              ... .experimental_task$, 
              ... .participant_number$,
              ... .extension$
  .pattern$ = audio_pattern.pattern$
  
  # Set the [.filename$] of the audio recording.
  @audio_filename: .pattern$
  .filename$ = audio_filename.filename$
  
  # Set the [.read_from$] and [.write_to$] filepaths of the audio recording.
  @audio_filepaths: .directory$,
                ... .filename$
  .read_from$ = audio_filepaths.read_from$
  .write_to$  = audio_filepaths.write_to$
  
  # Load the audio file as a Praat Sound object.
  @load_audio: .read_from$
  .praat_obj$ = load_audio.praat_obj$
  
  # Print an error message if a Praat Sound object was not created.
  if .praat_obj$ == ""
    @audio_error: .directory$,
              ... .participant_number$
  endif
endproc


