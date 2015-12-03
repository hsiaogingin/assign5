
PImage start1, start2, end1, end2, bg1, bg2, hp, enemy, treasure, fighter, bullet;
PImage [] flaming = new PImage[5];
PFont scoreBoard;
int score = 0;
int bulletNum = 0;
boolean [] bulletLimit = new boolean[5];
int hpX;
int timer;
int flameNum;
int closeEnemy;

int status;
final int GAME_START = 0;
final int GAME_PLAYING = 1;
final int GAME_LOSE = 2;

int enemyStatus;
final int ENEMY_STRAIGHT = 0;
final int ENEMY_SLOPE = 1;
final int ENEMY_DIAMOND = 2;

float treasureX;
float treasureY;
int fighterX; 
int fighterY;
int enemyCount = 8;
int bulletCount = 5;
int[] enemyX = new int[enemyCount];
int[] enemyY = new int[enemyCount];
float [] bulletX = new float[5];
float [] bulletY = new float[5];
float hitPos [][] = new float[5][2];

float fighterSpeed;
int bulletSpeed;
int bg1Pos = 640;
int bg2Pos = 0;

boolean upPressed = false;
boolean downPressed = false;
boolean leftPressed = false;
boolean rightPressed = false;

void setup () {
  size(640, 480) ;
  start1 = loadImage("img/start1.png");
  start2 = loadImage("img/start2.png");
  bg1 = loadImage("img/bg1.png");
  bg2 = loadImage("img/bg2.png");
  end1 = loadImage("img/end1.png");
  end2 = loadImage("img/end2.png");
  fighter = loadImage("img/fighter.png");
  enemy = loadImage("img/enemy.png");
  treasure = loadImage("img/treasure.png");
  hp = loadImage("img/hp.png");
  bullet = loadImage("img/shoot.png");
  for(int i=0; i<5; i++){ 
    flaming[i] = loadImage("img/flame" + (i+1) +".png");
  }
  
  status = GAME_START;
  enemyStatus = ENEMY_STRAIGHT;
  hpX = 40;
  fighterX = 500;
  fighterY = height/2;
  treasureX = floor(random(50, width - 40));
  treasureY = floor(random(50, height - 60));
  fighterSpeed = 3;
  bulletSpeed = 6;
  
  timer = 0;
  scoreBoard = createFont("Comic Sans MS", 24);
  textFont(scoreBoard, 16);
  flameNum = 0;
  for(int i=0; i<hitPos.length; i++){
    hitPos[i][0] = 2000;
    hitPos[i][1] = 2000;
  }
  
  for(int i=0; i<bulletLimit.length; i++){
    bulletLimit[i] = false;
  }
  
}


void draw()
{
  background(0);
  switch(status){
    case GAME_START:
      image(start2, 0, 0);
      if(mouseX > 200 && mouseX < 460 && mouseY > 370 && mouseY < 420){
        image(start1, 0, 0);  
        if(mousePressed){
          status = GAME_PLAYING;
        }
      }
    break; 
    
    case GAME_PLAYING:
      drawBg();
      drawHP();
      
      //treasure
      image (treasure, treasureX, treasureY);    
      if(getHit(treasureX, treasureY, treasure.width, treasure.height, 500, width/2, fighter.width, fighter.height) == true){  
        treasureX = floor( random(50, width-40) ); 
        treasureY = floor( random(50, height-60) );  
      }
      
      //fighter
      image(fighter, fighterX, fighterY);
      if (upPressed && fighterY > 0){
        fighterY -= fighterSpeed ;
      }if (downPressed && fighterY < height - fighter.height){
        fighterY += fighterSpeed ;
      }if (leftPressed && fighterX > 0){
        fighterX -= fighterSpeed ;
      }if (rightPressed && fighterX < width - fighter.width){
        fighterX += fighterSpeed ;
      }
      
      //flame
      timer++;
      image(flaming[flameNum], hitPos[flameNum][0], hitPos[flameNum][1]);
      if(timer % (60/10) == 0){
        flameNum++;
        if(flameNum>4){
          flameNum = 0;
        }
      }
      if(timer > 31){
        for(int i=0; i<5; i++){
          hitPos[i][0] = 2000;
          hitPos[i][1] = 2000;
        }
      }
      
      //shoot bullet
      for(int i=0; i<5; i++){
        if(bulletLimit[i] == true){
          image(bullet, bulletX[i], bulletY[i]);
          bulletX[i] -= bulletSpeed;
        }
        if(bulletX[i] < -bullet.width){
          bulletLimit[i] = false;
        }
      }
      
      //bullet hit
      for(int i=0; i< bulletCount; i++){
        if(enemyX[0] > 0){
          if(closeEnemy != -1 && enemyX[closeEnemy] < bulletX[i]){
            if(enemyY[closeEnemy] > bulletY[i]){
              bulletY[i] += 3;
            }else if(enemyY[closeEnemy] < bulletY[i]){
              bulletY[i] -= 3;
            }
          }
        }
      }
      
      //enemy
      switch(enemyStatus){
        case ENEMY_STRAIGHT:
          drawEnemy();
          for(int i=0; i<5; i++){      
            for(int j=0; j<5; j++){
                if(getHit(bulletX[j], bulletY[j], bullet.width, bullet.height, enemyX[i], enemyY[i], enemy.width, enemy.height) == true && bulletLimit[j] == true){
                  for (int k=0;  k<5; k++){
                    hitPos[k][0] = enemyX[i];
                    hitPos[k][1] = enemyY[i];
                  }
                  enemyY[i] = -1000;
                  timer = 0;     
                  bulletLimit[j] = false;
                  scoreAdd(20);
                }
            }          
            if(getHit(fighterX, fighterY ,fighter.width, fighter.height, enemyX[i], enemyY[i], enemy.width, enemy.height) == true){
               for(int j = 0;  j < 5; j++){
                    hitPos[j][0] = enemyX[i];
                    hitPos[j][1] = enemyY[i];
               }             
               enemyY[i] = -1000;
               timer = 0; 
               hpChange(-20);
             }else if(hpX<=0){
                  reset();
             }   
           }          
           enemySelect(ENEMY_SLOPE);          
        break;
        
        case ENEMY_SLOPE:
          drawEnemy();
          for(int i=0; i<5; i++ ){
            for(int j=0; j<5; j++){
            if(getHit(bulletX[j], bulletY[j] ,bullet.width, bullet.height, enemyX[i], enemyY[i], enemy.width, enemy.height) == true && bulletLimit[j] == true){
                for(int k=0;  k<5; k++ ){
                  hitPos[k][0] = enemyX[i];
                  hitPos[k][1] = enemyY[i];
                }     
                enemyY[i] = -1000;
                bulletLimit[j] = false;
                timer = 0;
                scoreAdd(20);
              }
            }

            if(getHit(fighterX, fighterY ,fighter.width, fighter.height, enemyX[i], enemyY[i], enemy.width, enemy.height) == true){
              for(int j=0;  j<5; j++ ){
                 hitPos[j][0] = enemyX[i];
                 hitPos[j][1] = enemyY[i];
               }
              enemyY[i] = -1000;
              timer = 0; 
              hpChange(-20);
            } else if (hpX <= 0) {
              reset();
            }  
          }      
          enemySelect(ENEMY_DIAMOND);      
        break;
        
        case ENEMY_DIAMOND:
          drawEnemy();      
          for(int i=0; i<8; i++ ){    
            for(int j=0; j<5; j++ ){
              if(getHit(bulletX[j], bulletY[j], bullet.width, bullet.height, enemyX[i],enemyY[i], enemy.width, enemy.height) == true && bulletLimit[j] == true){
                for(int k=0; k<5; k++){
                  hitPos[k][0] = enemyX[i];
                  hitPos[k][1] = enemyY[i];
                }
                enemyY[i] = -1000;
                bulletLimit[j] = false;
                timer = 0; 
                scoreAdd(20);
              }
            }       
                
            if(getHit(fighterX, fighterY ,fighter.width, fighter.height, enemyX[i] ,enemyY[i], enemy.width, enemy.height) == true){
              for (int j=0; j<5; j++ ){
                hitPos[j][0] = enemyX[i];
                hitPos[j][1] = enemyY[i];
              }
              hpChange(-20);
              enemyY[i] = -1000;
              timer = 0; 
              
            } else if(hpX<= 0 ){
              reset();
            }    
          }         
          enemySelect(ENEMY_STRAIGHT);
        break;
      }
     
      fill(255);
      text("Score:" + score, 30, 450);
    break;
    
    case GAME_LOSE:
      image(end2, 0, 0);  
        if(mouseX > 200 && mouseX < 470 && mouseY > 300 && mouseY < 350){
          image(end1, 0, 0);
          if(mousePressed){
            status = GAME_PLAYING; 
            enemyStatus = ENEMY_STRAIGHT;
            addEnemy(ENEMY_STRAIGHT);
            for (int i = 0; i < 5; i++ ){
              hitPos[i][0] = 1000;
              hitPos[i][1] = 1000;
              bulletLimit[i] = false;       
            }
          }
        }
    break;
  }
  
  for (int i = 0; i < enemyCount; ++i) {
    if (enemyX[i] != -1 || enemyY[i] != -1) {
      image(enemy, enemyX[i], enemyY[i]);
      enemyX[i]+=5;
    }
  }
  if(status!=1){
    for(int i = 0; i < enemyCount; i++){
        enemyX[i] = -500;
        enemyY[i] = -500;
      }
}
  
}

void drawBg(){
      image(bg1,-640+bg1Pos,0);
      image(bg2,-640+bg2Pos,0);
      bg1Pos += 10;
      bg1Pos = bg1Pos % 1280;
      bg2Pos += 10;
      bg2Pos = bg2Pos % 1280;
}

void drawHP(){
      fill(255,0,0);
      rect(35, 15, hpX, 30);
      image(hp, 30, 15);
      //get treasure
      if (getHit(fighterX, fighterY ,fighter.width, fighter.height,treasureX ,treasureY , treasure.width, treasure.height) == true) {
          treasureX = floor( random(50,600) );         
          treasureY = floor( random(50,420) );
          if(hpX < 200){
              hpChange(20);
          }
      }
}

void drawEnemy(){
  for(int i=0; i<enemyCount; ++i){
    if(enemyX[i] != -1 || enemyY[i] != -1){
      image(enemy, enemyX[i], enemyY[i]);
      enemyX[i]+=3;
    }
  }
}


// 0 - straight, 1-slope, 2-dimond
void addEnemy(int type)
{  
  for (int i = 0; i < enemyCount; ++i) {
    enemyX[i] = -1;
    enemyY[i] = -1;
  }
  switch (type) {
    case 0:
      addStraightEnemy();
      break;
    case 1:
      addSlopeEnemy();
      break;
    case 2:
      addDiamondEnemy();
      break;
  }
}

void addStraightEnemy()
{
  float t = random(height - enemy.height);
  int h = int(t);
  for (int i = 0; i < 5; ++i) {

    enemyX[i] = (i+1)*-80;
    enemyY[i] = h;
  }
}

void addSlopeEnemy()
{
  float t = random(height - enemy.height * 5);
  int h = int(t);
  for (int i = 0; i < 5; ++i) {

    enemyX[i] = (i+1)*-80;
    enemyY[i] = h + i * 40;
  }
}

void addDiamondEnemy()
{
  float t = random( enemy.height * 3 ,height - enemy.height * 3);
  int h = int(t);
  int x_axis = 1;
  for (int i = 0; i < 8; ++i) {
    if (i == 0 || i == 7) {
      enemyX[i] = x_axis*-80;
      enemyY[i] = h;
      x_axis++;
    }
    else if (i == 1 || i == 5){
      enemyX[i] = x_axis*-80;
      enemyY[i] = h + 1 * 40;
      enemyX[i+1] = x_axis*-80;
      enemyY[i+1] = h - 1 * 40;
      i++;
      x_axis++;
      
    }
    else {
      enemyX[i] = x_axis*-80;
      enemyY[i] = h + 2 * 40;
      enemyX[i+1] = x_axis*-80;
      enemyY[i+1] = h - 2 * 40;
      i++;
      x_axis++;
    }
  }
}


boolean getHit(float ax, float ay, float aw, float ah, float bx, float by, float bw, float bh){
  if (ax >= bx - aw && ax <= bx + bw && ay >= by - ah && ay <= by + bh){
  return true;
  }
  return false;
}

void enemySelect(int state){
  if(enemyX[5] == -1 && enemyX[4] > width+200){
    enemyStatus = state;
    addEnemy(state);
  }else if(enemyX[7] > width+400){
    enemyStatus = state;
    addEnemy(state);
  }
}

void scoreAdd(int value){
  score += value;
}

void hpChange(int value){
  hpX += value;
}


void reset(){
  status = GAME_LOSE;
  hpX = 40;
  fighterX = 500;
  fighterY = height/2;
  treasureX = floor( random(50,600) );
  treasureY = floor( random(50,420) );
  score = 0;
}


int closeEnemy(int fighterXCurrent, int fighterYCurrent){
  float enemyDistance = 1000;
  if(enemyX[7] > width || enemyX[5] == -1 && enemyX[4] > width){
    closeEnemy = -1;
  }else{
    for(int i=0; i<8; i++){
      if(enemyX[i] != -1){
        if(dist(fighterXCurrent, fighterYCurrent, enemyX[i], enemyY[i]) < enemyDistance){
          enemyDistance = dist(fighterXCurrent, fighterYCurrent, enemyX[i], enemyY[i]);
          closeEnemy = i;
        }
      }
    }
  }
  return closeEnemy;
}


void keyPressed (){
   if (key == CODED){ 
    switch (keyCode) {
      case UP :
        upPressed = true ;
        break ;
      case DOWN :
        downPressed = true ;
        break ;
      case LEFT :
        leftPressed = true ;
        break ;
      case RIGHT :
        rightPressed = true ;
        break ;
    }
  }
   if(key == ENTER){
        switch(status) {  
           case GAME_START:       
             image(start1, 0, 0);  
             status = GAME_PLAYING;
           break;
           
           case GAME_LOSE:
            image(end1, 0, 0);
            status = GAME_PLAYING; 
            enemyStatus = ENEMY_STRAIGHT;
            addEnemy(ENEMY_STRAIGHT);
            for (int i = 0; i < 5; i++ ){
              hitPos[i][0] = 1000;
              hitPos[i][1] = 1000;
              bulletLimit[i] = false;       
            }
           break;
       } 
     }
}


void keyReleased () {
 if (key == CODED){ 
  switch ( keyCode ) {
    case UP : 
      upPressed = false ;
      break ;
    case DOWN :
      downPressed = false ;
      break ;
    case LEFT :
      leftPressed = false ;
      break ;
    case RIGHT :
      rightPressed = false ;
      break ;
      }  
  }
  
  if (keyCode == ' '){
      if(status ==  1){
        if(bulletLimit[bulletNum] == false ) {
          bulletLimit[bulletNum] = true;
          bulletX[bulletNum] = fighterX - 10;
          bulletY[bulletNum] = fighterY + fighter.height/2;
          bulletNum++;
        }   
        if(bulletNum > 4) {
          bulletNum = 0;
        }
      }
   }
}
