void createGui()
{
  gui.addButton("playButton")
    .setLabel("Play")
      .setPosition(10, 10)
        .setSize(50, 50).
          getCaptionLabel()
          .align(ControlP5.CENTER, ControlP5.CENTER);

  gui.addButton("stopButton")
    .setLabel("Stop")
      .setPosition(70, 10)
        .setSize(50, 50).
          getCaptionLabel()
          .align(ControlP5.CENTER, ControlP5.CENTER);

  gui.addButton("pitchButton")
    .setLabel("Pitch")
      .setPosition(130, 10)
        .setSize(50, 50).
          getCaptionLabel()
          .align(ControlP5.CENTER, ControlP5.CENTER);

  gui.addButton("playbackButton")
    .setLabel("PlayBack")
      .setPosition(190, 10)
        .setSize(50, 50).
          getCaptionLabel()
          .align(ControlP5.CENTER, ControlP5.CENTER);

  gui.addButton("nextButton")
    .setLabel("Next")
      .setPosition((width/2)+35, 10)
        .setSize(50, 50)
          .getCaptionLabel()
            .align(ControlP5.CENTER, ControlP5.CENTER);

  gui.addButton("previousButton")
    .setLabel("Previous")
      .setPosition((width/2)-85, 10)
        .setSize(50, 50)
          .getCaptionLabel()
            .align(ControlP5.CENTER, ControlP5.CENTER);

  gui.addButton("redoButton")
    .setLabel("Redo")
      .setPosition((width/2)-25, 10)
        .setSize(50, 50).
          getCaptionLabel()
          .align(ControlP5.CENTER, ControlP5.CENTER);


  gui.addButton("websiteLink")
    .setLabel("Find a bug?")
      .setPosition(0, height-20)
        .setSize(70, 20)
          .getCaptionLabel()
            .align(ControlP5.CENTER, ControlP5.CENTER);

  setLock(gui.getController("playButton"), true);
  setLock(gui.getController("stopButton"), true);
  setLock(gui.getController("pitchButton"), true);
  setLock(gui.getController("playbackButton"), true);
  setLock(gui.getController("previousButton"), true);
  setLock(gui.getController("redoButton"), true);

  gui.addSlider("tempoSlider")
    .setLabel("Tempo")
      .setPosition(10, 80)
        .setSize(20, 200)
          .setRange(40, 280)
            .setValue(40)
              .setDecimalPrecision(0)
                .setColorForeground(color(0, 128, 0))
                  .setColorActive(color(0, 200, 0));

  gui.getController("tempoSlider").getCaptionLabel()
    .setPaddingX(5)
      .align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE)
        .setColor(color(0));
  gui.getController("tempoSlider").getValueLabel()
    .setPaddingX(0)
      .align(ControlP5.CENTER, -200)
        .setColor(color(255));

  gui.addSlider("volumeSlider")
    .setLabel("vol")
      .setPosition(10, 300)
        .setSize(20, 200)
          .setRange(0, 100)
            .setDecimalPrecision(0)
              .setValue(50);

  gui.getController("volumeSlider").getCaptionLabel()
    .align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE)
      .setPaddingX(0)
        .setColor(color(0));
  gui.getController("volumeSlider").getValueLabel()
    .setPaddingX(0)
      .align(ControlP5.CENTER, -200)
        .setColor(color(255));


  gui.addSlider("micLevel")
    .setLabel("mic")
      .setPosition(40, 300)
        .setSize(20, 200)
          .setRange(0, 100)
            .lock()
              ;

  gui.getController("micLevel").getCaptionLabel()
    .align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE)
      .setPaddingX(0)
        .setColor(color(0));
  gui.getController("micLevel").getValueLabel().setVisible(false);

  gui.getController("tempoSlider").setValue((int)module.getTempo());

  metro = gui.addCheckBox("metroBangFoo")
    .setPosition(SIDEBAR_WIDTH+(width-SIDEBAR_WIDTH)/2-250, height-120)
      .setSize(500, 100)
        .setItemsPerRow(1)
          .addItem("1", 0)
            .hide()
              ;

  progressGroup = gui.addGroup("progress")
  .open()
    .hideBar()
      .setBackgroundColor(#E5E6E8)
        .setPosition(SIDEBAR_WIDTH, height/2+2*PADDING)
          .setSize(width-SIDEBAR_WIDTH, height/2-2*PADDING)
            ;

  scorecardGroup = gui.addGroup("scorecard")
    .hideBar()
      .setSize(width*2/3, height*2/3)
        .setPosition(width/6, height/6)
          .setBackgroundColor(#E5E6E8)
            .hide()
              ;

  optionGroup = gui.addGroup("options")
    .setLabel ("User and Module Options")
      .setPosition(width-220, 30)
        .setSize(220, 300)
          .setBarHeight(20)
            .setBackgroundColor(#E5E6E8)
              //.setColorForeground(color(255))
              .close()
                .hide()
                  ;

  optionGroup.getCaptionLabel()
    .align(ControlP5.CENTER, ControlP5.CENTER);


  gui.addButton("loadButton")
    .setLabel("Load user progress file")
      .setPosition(10, 10)
        .setSize(200, 50)
          .setGroup(optionGroup)
            .getCaptionLabel()
              .align(ControlP5.CENTER, ControlP5.CENTER);

  gui.addButton("saveButton")
    .setLabel("Save user progress file")
      .setPosition(10, 70)
        .setSize(200, 50)
          .setGroup(optionGroup)
            .getCaptionLabel()
              .align(ControlP5.CENTER, ControlP5.CENTER);

  gui.addButton("moduleButton")
    .setLabel("Load new Latido module")
      .setPosition(10, 130)
        .setSize(200, 50)
          .setGroup(optionGroup)
            .getCaptionLabel()
              .align(ControlP5.CENTER, ControlP5.CENTER);

  gui.addTextlabel("practiceLabel")
    .setText("PRACTICE MODE OFF")
      .setPosition(112, 196)
        .setColor(color(0))
          .setGroup(optionGroup);

  gui.addToggle("practiceToggle")
    .setLabel("Switch on/off Practice Mode")
      .setPosition(10, 190)
        .setSize(100, 20)
          .setValue(true)
            .setMode(ControlP5.SWITCH)
              .setGroup(optionGroup)
                .getCaptionLabel()
                  .setColor(color(0))
                    ;

  gui.addGroup("splash")
    .hideBar()
      //.hide()
      .setPosition(2*PADDING+SIDEBAR_WIDTH, 2*PADDING)
        .setSize((int)(width-SIDEBAR_WIDTH-4*PADDING), (int)(height-4*PADDING))
          .addCanvas(new Splash())
            ;

  textbox = gui.addTextarea("text")
    .setPosition(SIDEBAR_WIDTH+PADDING, TOPBAR_HEIGHT+PADDING)
      .setSize(width - SIDEBAR_WIDTH - 2*PADDING, height/2-PADDING)
        .setColorBackground(color(255))
          .setColorForeground(color(0))
            .setColor(0) // text color
              .setFont(font)
                .setText("Lorem ipsem")
                  .hide();

  metro.getItem(0).getCaptionLabel()
    .setFont(createFont("", 48))
      .setSize(48)
        .align(ControlP5.CENTER, ControlP5.CENTER)
          .setColor(255);

  optionGroup.bringToFront();
  //gui.getTooltip().register("playButton", "Play the exercise");
  //gui.getTooltip().register("stopButton", "Stop playback");
  gui.getTooltip().register("pitchButton", "Hear your starting pitch");
  gui.getTooltip().register("playbackButton", "Hear your last attempt");
  //gui.getTooltip().register("previousButton", "Go back to the previous exercise");
  //gui.getTooltip().register("redoButton", "Try the same exercise again");
  //gui.getTooltip().register("nextButton", "Go on to the next screen");
  gui.getTooltip().register("tempoSlider", "Adjust the playback tempo");
  gui.getTooltip().register("volumeSlider", "Adjust the playback volume");
}

