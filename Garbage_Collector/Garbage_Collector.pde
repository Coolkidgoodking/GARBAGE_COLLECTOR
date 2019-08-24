// Pointer is client, stack player is server

import java.util.Date;

PImage ptrImg;  // Declare a variable of type PImage
PImage stkImg;
PImage menuBg;
PImage eyeImg;
PImage bombImg;
PImage bootsImg;
PImage heartImg;
PImage greenPtr;
PImage pointerOption, stackOption;
int menuOption = 0; //0 is pointer, 1 is stack


int POINTER_AMOUNT = 100;

PFont font;

PointerPlayer ptrBoi;
StackPlayer stkBoi;
Map map;
Void papaVoid;
Pointer[] pointers = new Pointer[POINTER_AMOUNT];
Animation zoomGif;
Animation stkHit;

// Power ups
int itemsInGame = 0;
Eye eye;


boolean gameStarted = false;
boolean zoomAnimationPlaying = false;
Date animationStart;

//screen size CANNOT be a variable, this is used for map translations
int SCREEN_X = 800;
int SCREEN_Y = 600;



void setup() {
  size(800, 600);
  ptrImg = loadImage("../Sprites/pointer_ai.png");
  stkImg = loadImage("stack_base.png");
  greenPtr = loadImage("PowerUps/greenPointer.png");
  eyeImg = loadImage("PowerUps/Eye.jpg");
  bombImg = loadImage("PowerUps/Bomb.jpg");
  bootsImg = loadImage("PowerUps/Boots.jpg");
  //heartImg = loadImage("PowerUps/Heart.jpg");
  
  //eyeImg = loadImage("") // TODO
  menuBg = loadImage("computer.png");
  font = createFont("COMIC.TTF", 24);
  textFont(font);
  zoomGif = new Animation("MenuAnimation/menu_sprite", 51, "jpg");
  stkHit = new Animation("stackHitAnimation/stack_hit", 8, "png");
  pointerOption = loadImage("option_pointer.png");
  stackOption = loadImage("option_stack.png");
  
  
  ptrBoi = new PointerPlayer();
  stkBoi = new StackPlayer();
  map = new Map();

  //powerups
  eye = new Eye();
  
  papaVoid = new Void(width, height);
  for (int i = 0; i < POINTER_AMOUNT; ++i) {
    pointers[i] = new Pointer();
  }

  frameRate(30);
  background(0);
}

/*
event call back that gets run once when a key is pressed.
TODO: prevent starvation as one player holds down a key
*/
void keyPressed() {
  
  if (!gameStarted) {
    if (keyCode == ENTER) {
      zoomAnimationPlaying = true;
      animationStart = new Date();
    }
    if (keyCode == UP) {
       menuOption = 0; 
    } else if (keyCode == DOWN) {
       menuOption = 1; 
    }
    //this.menuOption = 1;
  }
  
  if (key == CODED) {
    if (keyCode == RIGHT || keyCode == LEFT || keyCode == UP || keyCode == DOWN) {
      if (menuOption == 1) {
        stkBoi.move(keyCode);
      } else {
         ptrBoi.move(keyCode);
      }
      
    }
  } else if (key == ' ' && menuOption == 1) {
    stkBoi.attackPointer();
  } else if(key == ' ') {
   ptrBoi.sacrificePointer(); 
  }
     
  //println("ptrPos: " + ptrBoi.x + ":" + ptrBoi.y);
  // stk movement (it's slower than ptr)
  key = Character.toLowerCase(key);
  // stk movement (it's slower than ptr)
  key = Character.toLowerCase(key);
  if (key == 'w' || key == 's' || key == 'a' || key == 'd') {
    stkBoi.move(key);
  }
    
} 

void draw() {
  if (!gameStarted) {
    if (!zoomAnimationPlaying) {
      //draw main menu
      image(menuBg, -50, 0);
      if (menuOption == 0) {
        image(pointerOption, 90, -20, 800 * 0.8, 600 * 0.8);
      } else {
        image(stackOption, 90, -20, 800 * 0.8, 600 * 0.8);
      }
    }  else { //use time-variable busy waiting
      zoomGif.display(0, 0, 800, 600);
      Date now = new Date();
      println(now.getTime() - animationStart.getTime());
      if (now.getTime() - animationStart.getTime() > 1500) {
        gameStarted = true;
      }
    }
    
  } else {
    background(0); //this is REDRAW
    int ptrSection = map.getSectionByXY(ptrBoi.x, ptrBoi.y);
    for (int i = 0; i < POINTER_AMOUNT; ++i) {
      ptrBoi.collectCount += pointers[i].collision(ptrBoi.x, ptrBoi.y, 17, 17);
      pointers[i].display(ptrSection);
    }
    papaVoid.display(ptrSection);
    // I know this should be in a class, will do later
    if (papaVoid.collision(ptrBoi.x, ptrBoi.y, 17, 17)) {
      ptrBoi.stashCount += ptrBoi.collectCount;
      ptrBoi.collectCount = 0;
      if (papaVoid.x < ptrBoi.x) {
        ptrBoi.canLeft = false;
      } else {
        ptrBoi.canRight = false;
      }
      
      if (papaVoid.y < ptrBoi.y) {
        ptrBoi.canUp = false;
      } else {
        ptrBoi.canDown = false;
      }
    } else {
      ptrBoi.freeMove();
    }
    // Check Powerups 
    eye.update();
    eye.checkCollision(stkBoi.x,stkBoi.y, 17, 17);
    
    
    ptrBoi.render();
    ptrBoi.calcSpeed();
    stkBoi.render();
    text("Memory Stolen:", 10, 30);
    text(ptrBoi.collectCount, 195, 30);
    text("Memory Stashed:", 10, 60);
    text(ptrBoi.stashCount, 215, 60);
  }
}
