import ddf.minim.*;
//ブロックについて
//blockHP(0から100)が0でブロック消滅
/*　  name       | number   |   code
 虚無　　　　　　[0]         ---
 --------------------------------------------
 1/7水           [1]
 2/7水　　　　　 [2]
 3/7水　　　　　 [3]
 4/7水　　　　　 [4]
 5/7水　　　　　 [5]
 6/7水　　　　　 [6]
 固定水　　　　　[7]         water
 --------------------------------------------
 土ブロック　　　[10]　      dirt
 土ブロック(草)　[11]        dirt_grass
 石ブロック　　　[12]        stone
 着火石　　　　　[13]        石炭         
 オーク          [31]        oak
 葉っぱ　　　　　[32]        leaves
 オークプランク　[33]        oak_planks
 --------------------------------------------
 木の棒　　　　　[100]       stick
 木のツルハシ　　[101]       wooden_pickaxe
 
 (破壊演出　　　 [20-30]      ---)
 */
PImage dirt;
PImage dirt_grass_top;
PImage dirt_grass_side;
PImage coal_ore;
PImage coal;
PImage oak_top;
PImage oak_side;
PImage oak_leaves;
PImage oak_planks;
PImage stone;
PImage water;

PImage stick;
PImage wooden_pickaxe;
PImage[] delete_level;
Minim minim;
AudioPlayer background_music;
AudioPlayer Catch;
AudioPlayer diving;
AudioPlayer walk4;
void load() {
  dirt = loadImage("assets/dirt.png");
  dirt_grass_side = loadImage("assets/dirt_grass_side.png");
  dirt_grass_top = loadImage("assets/dirt_grass_top.png");
  coal_ore = loadImage("assets/coal_ore.png");
  oak_top = loadImage("assets/oak_top.png");
  oak_side = loadImage("assets/oak_side.png");
  oak_leaves = loadImage("assets/oak_leaves.png");
  oak_planks = loadImage("assets/oak_planks.png");
  stone = loadImage("assets/stone.png");
  water = loadImage("assets/water.png");
  delete_level = new PImage[19];
  delete_level[0] = loadImage("assets/delete_level0.png");
  delete_level[1] = loadImage("assets/delete_level1.png");
  delete_level[2] = loadImage("assets/delete_level2.png");
  delete_level[3] = loadImage("assets/delete_level3.png");
  delete_level[4] = loadImage("assets/delete_level4.png");
  delete_level[5] = loadImage("assets/delete_level5.png");
  delete_level[6] = loadImage("assets/delete_level6.png");
  delete_level[7] = loadImage("assets/delete_level7.png");
  delete_level[8] = loadImage("assets/delete_level8.png");
  delete_level[9] = loadImage("assets/delete_level9.png");
  delete_level[10] = loadImage("assets/delete_level10.png");
  delete_level[11] = loadImage("assets/delete_level11.png");
  delete_level[12] = loadImage("assets/delete_level12.png");
  delete_level[13] = loadImage("assets/delete_level13.png");
  delete_level[14] = loadImage("assets/delete_level14.png");
  delete_level[15] = loadImage("assets/delete_level15.png");
  delete_level[16] = loadImage("assets/delete_level16.png");
  delete_level[17] = loadImage("assets/delete_level17.png");
  delete_level[18] = loadImage("assets/delete_level18.png");

  stick = loadImage("assets/stick.png");
  wooden_pickaxe = loadImage("assets/wooden_pickaxe.png");
  coal = loadImage("assets/coal.png");
  
  background_music = minim.loadFile("music/background_music.mp3");
  Catch = minim.loadFile("music/catch.mp3");
  diving = minim.loadFile("music/diving.mp3");
  walk4 = minim.loadFile("music/walk4.mp3");
}
// world
int worldX=1024;
int worldY=50;
int worldZ=1024;
int[][][] map=new int[worldX][worldZ][worldY];
// chunk
int MAX_view_distance = 20; // 可視範囲調整はココ
int chunkSize = 8; // チャンク単位調整はココ
int chunkCountX = worldX / chunkSize;
int chunkCountY = worldY / chunkSize;
int chunkCountZ = worldZ / chunkSize;
Chunk[][][] chunks = new Chunk[chunkCountX][chunkCountZ][chunkCountY];
// user
float camX=worldX/2;
float camY=worldY-2;
float camZ=worldZ/2;
// angle
float angleH=radians(0);
float angleV=radians(0);
// item
Item item[];
int hothotItem = 0;
Item craftedItem = null;
Item craftItem[][];

float stride=0.1;
float gravity=19.6;
float velocityV = 0;
int blockHP=100;
boolean inventory=false;
boolean E_Released=false;
boolean mouseReleased = true;
Item hotItem = null;
boolean[] keys=new boolean[256];
FocusBlock_and_PuttablePosition focusBlock_and_puttablePosition;
FocusBlock_and_PuttablePosition PfocusBlock_and_puttablePosition;
ArrayList<DroppedItem>droppedItem = new ArrayList<DroppedItem>();
ArrayList<Recipe> recipe = new ArrayList<Recipe>();
BlockData block_data[];
float nextX=camX, nextY=camY, nextZ=camZ;
float nextralX=camX, nextralZ=camZ;
void setup() {
  //チャンクの初期化
  for (int i = 0; i < chunkCountX; i++) {
    for (int j = 0; j < chunkCountZ; j++) {
      for (int k = 0; k < chunkCountY; k++) {
        chunks[i][j][k] = new Chunk(i * chunkSize, j * chunkSize, k * chunkSize, chunkSize);
      }
    }
  }
  minim = new Minim(this);
  load();
  background_music.loop();
  fullScreen(P3D);
  noCursor();
  noStroke();
  perspective(radians(60), width/(float)height, 0.01, 100);

  // アイテム初期化
  item = new Item[36];
  craftItem = new Item[3][3];
  item = new Item[36];

  // ブロックはここに(block_type 1:全部写真同じ,2:横と上下違う写真,3:横と上と下違う写真,4左右と前後と上下違う写真,5:流体,6:アイテム)
  // 3の場合(int block_type, PImage block_img, PImage block_img2(下面), PImage block_img3(上面), int block_softness, int block_change)
  //
  block_data = new BlockData[200];

  block_data[0] = new BlockData(0, null, null, null, 0, 0);// 空気

  block_data[1] = new BlockData(5, null, null, null, 0, 0);// 1/7水
  block_data[2] = new BlockData(5, null, null, null, 0, 0);// 2/7水
  block_data[3] = new BlockData(5, null, null, null, 0, 0);// 3/7水
  block_data[4] = new BlockData(5, null, null, null, 0, 0);// 1/7水
  block_data[5] = new BlockData(5, null, null, null, 0, 0);// 1/7水
  block_data[6] = new BlockData(5, null, null, null, 0, 0);// 1/7水
  block_data[7] = new BlockData(5, null, null, null, 0, 0);// 1/7水

  block_data[10] = new BlockData(1, dirt, null, null, 4, 10);//土ブロック
  block_data[11] = new BlockData(3, dirt_grass_side, dirt, dirt_grass_top, 4, 10);//土ブロック(草)
  block_data[12] = new BlockData(1, stone, null, null, 2, 12);//石ブロック
  block_data[13] = new BlockData(1, coal_ore, null, null, 2, 12);//石炭
  block_data[31] = new BlockData(2, oak_side, oak_top, null, 3, 31);//オーク(幹)
  block_data[32] = new BlockData(1, oak_leaves, null, null, 5, 0);//オーク(葉)
  block_data[33] = new BlockData(1, oak_planks, null, null, 3, 33);//オークプランク

  block_data[100] = new BlockData(6, stick, null, null, 0, 0);//木の棒
  block_data[101] = new BlockData(6, wooden_pickaxe, null, null, 0, 0);//木のつるはし
  
  // レシピはここに Recipe(生成品,生成量,素材1,素材2,素材3,素材4,素材5,素材6,素材7,素材8,素材9)
  recipe.add(new Recipe(33, 9, 31, 31, 31, 31, 31, 31, 31, 31, 31));  //oak_planks
  recipe.add(new Recipe(100, 9, 0, 0, 0, 33, 33, 33, 0, 0, 0));  //stick
  recipe.add(new Recipe(100, 9, 0, 0, 0, 33, 33, 33, 0, 0, 0));  //stick
  
  generate_world();
}
void draw() {
  //光の設定
  ambientLight(255, 255, 255);
  directionalLight(150, 150, 150, -1, -1, 0);
  //  キー管理
  //　座標更新の提案
  if (!inventory) {
    if (keys['w']) {
      nextX = vectorX(stride);
      nextralX = vectorX(stride*5);
      nextZ = vectorZ(stride);
      nextralZ = vectorZ(stride*5);
      if (block_data[onBlock()].block_softness == 4) {
        // サウンド巻き戻し
        walk4.rewind();
        walk4.play();
      }
    }
    if (keys['s']) {
      nextX = vectorX(stride*-1);
      nextralX = vectorX(stride*5*-1);
      nextZ = vectorZ(stride*-1);
      nextralZ = vectorZ(stride*5*-1);
    }
    if (keys['1'])hothotItem=0;
    if (keys['2'])hothotItem=1;
    if (keys['3'])hothotItem=2;
    if (keys['4'])hothotItem=3;
    if (keys['5'])hothotItem=4;
    if (keys['6'])hothotItem=5;
    if (keys['7'])hothotItem=6;
    if (keys['8'])hothotItem=7;
    if (keys['9'])hothotItem=8;
  }

  if (E_Released &&inventory==false&&keys['e']) {
    inventory = true;
    E_Released = false;
  }
  if (E_Released &&inventory==true&&keys['e']) {
    inventory = false;
    E_Released = false;
  }
  if (!keys['e']) E_Released = true;
  //水中の処理
  if (inWater()) {
    diving.play();
    nextY = camY + -0.5 * 1.0 / frameRate;
    if (!inventory) {
      if (keys[' ']) {
        if (map[round(camX)][round(camZ)][round(camY-1.4)]!=0&&map[round(camX)][round(camZ)][round(camY-1.4)]<10)
          nextY += 0.1;
      }
      if (keys['z']) {
        if (map[round(camX)][round(camZ)][round(camY-1.4)]!=0&&map[round(camX)][round(camZ)][round(camY-1.4)]<10)
          nextY -= 0.1;
      }
    }
  } else {
    diving.rewind();
    nextY = camY + velocityV * 1.0 / frameRate;
  }

  if (!isHit_V()) {
    velocityV -= gravity * 1.0 / frameRate;
  } else {
    velocityV = 0;
    if (keys[' ']&&can_i_jump()&&!inventory)velocityV = 6;
  }
  if (!isHit_H()) {
    camX = nextX;
    camZ = nextZ;
  }
  camY = nextY;
  //描画処理のスペース
  if (!inWater_eye())background(126, 192, 255);
  else background(#2634ad, 200);

  for (int i = 0; i < chunkCountX; i++) {
    for (int j = 0; j < chunkCountZ; j++) {
      for (int k = 0; k < chunkCountY; k++) {
        if (can_i_draw_this_chunk(i, j, k)) {
          chunks[i][j][k].drawing();
        }
      }
    }
  }
  //落下アイテムの処理
  for (int i = 0; i< droppedItem.size(); i++) {
    droppedItem.get(i).drawing();
    if (dist(camX, camZ, camY-1.5, droppedItem.get(i).x, droppedItem.get(i).z, droppedItem.get(i).y)<2) {
      Catch.play();
      Catch.rewind();
      getItem(droppedItem.get(i).item_num);
      droppedItem.remove(i);
    }
  }
  //フォーカスブロックの処理
  PfocusBlock_and_puttablePosition = focusBlock_and_puttablePosition ;
  focusBlock_and_puttablePosition = focusBlock_and_puttablePosition();

  if (focusBlock_and_puttablePosition.bool&&!inventory) {
    stroke(0);
    switch (block_data[map[focusBlock_and_puttablePosition.Fx][focusBlock_and_puttablePosition.Fz][focusBlock_and_puttablePosition.Fy]].block_type) {
    case 1:
      Draw_Block(focusBlock_and_puttablePosition.Fx, focusBlock_and_puttablePosition.Fz, focusBlock_and_puttablePosition.Fy, map[focusBlock_and_puttablePosition.Fx][focusBlock_and_puttablePosition.Fz][focusBlock_and_puttablePosition.Fy]);
      break;
    case 2:
      Draw_Block2(focusBlock_and_puttablePosition.Fx, focusBlock_and_puttablePosition.Fz, focusBlock_and_puttablePosition.Fy, map[focusBlock_and_puttablePosition.Fx][focusBlock_and_puttablePosition.Fz][focusBlock_and_puttablePosition.Fy]);
      break;
    case 3:
      Draw_Block3(focusBlock_and_puttablePosition.Fx, focusBlock_and_puttablePosition.Fz, focusBlock_and_puttablePosition.Fy, map[focusBlock_and_puttablePosition.Fx][focusBlock_and_puttablePosition.Fz][focusBlock_and_puttablePosition.Fy]);
      break;
    default:
      break;
    }
    if (mousePressed&&mouseButton==LEFT&&isSame()&& map[focusBlock_and_puttablePosition.Fx][focusBlock_and_puttablePosition.Fz][focusBlock_and_puttablePosition.Fy]>=10) {
      blockHP -= block_data[map[focusBlock_and_puttablePosition.Fx][focusBlock_and_puttablePosition.Fz][focusBlock_and_puttablePosition.Fy]].block_softness;
      //消滅時の処理
      if (blockHP<0) {
        if (block_data[map[focusBlock_and_puttablePosition.Fx][focusBlock_and_puttablePosition.Fz][focusBlock_and_puttablePosition.Fy]].block_change!=0) droppedItem.add(new DroppedItem(focusBlock_and_puttablePosition.Fx+random(-0.2, 0.2), focusBlock_and_puttablePosition.Fz+random(-0.2, 0.2), focusBlock_and_puttablePosition.Fy, block_data[map[focusBlock_and_puttablePosition.Fx][focusBlock_and_puttablePosition.Fz][focusBlock_and_puttablePosition.Fy]].block_change));
        map[focusBlock_and_puttablePosition.Fx][focusBlock_and_puttablePosition.Fz][focusBlock_and_puttablePosition.Fy]=0;
      }
      if (map[focusBlock_and_puttablePosition.Fx][focusBlock_and_puttablePosition.Fz][focusBlock_and_puttablePosition.Fy] >= 10) DeleteEffect(focusBlock_and_puttablePosition.Fx, focusBlock_and_puttablePosition.Fz, focusBlock_and_puttablePosition.Fy, blockHP);
    } else blockHP=100;
    noStroke();
  }
  if (!inventory) {
    //　水平角度
    angleH += (pmouseX-mouseX)/200.0;
    if (angleH < 0) {
      angleH += 360;
    }
    if (angleH>360) {
      angleH -= 360;
    }
    angleV = radians(180 + (mouseY - (height / 2.0)) / 2.0);
    angleV = constrain(angleV, radians(110), radians(255));
  }
  if (!mousePressed) {
    mouseReleased = true;
  }
  // 以下2D描画のすぺーす
  pushMatrix();
  resetMatrix();
  camera();
  ortho();
  hint(DISABLE_DEPTH_TEST);
  // ここから
  textSize(32);
  text(frameRate, 0, 100);
  if (inventory) {
    Inventory();
    cursor();
  } else {
    hotBar();
    noCursor();
  }
  hint(ENABLE_DEPTH_TEST);
  popMatrix();
  perspective(radians(60), width/(float)height, 0.01, 100);
  //　垂直角度
  camera(camX, camY, camZ, vectorX(1), vectorY(), vectorZ(1), 0, -1, 0); // カメラ設定を再適用
  if (mousePressed&&mouseButton==RIGHT&&mouseReleased&&!inventory) {
    PutBlock(focusBlock_and_puttablePosition.Px, focusBlock_and_puttablePosition.Pz, focusBlock_and_puttablePosition.Py);
  }
  if (mousePressed&&mouseButton==RIGHT&&mouseReleased) {
    mouseReleased=false;
  }
  if (mousePressed&&mouseButton==LEFT&&mouseReleased) {
    mouseReleased=false;
  }
}
void getItem(int item_number) {
  for (int i = 0; i<36; i++) {
    if (item[i]==null) {
      item[i] = new Item(item_number, 1);
      break;
    } else if (item[i].item_num==item_number&&item[i].amount<64) {
      item[i].amount ++;
      break;
    } else {
    }
  }
}
//　ベクター計算関数
float vectorX(float delta) {
  float vX = cos(angleV) * cos(angleH);
  float lookX = camX + vX * delta;
  return lookX;
}
float vectorZ(float delta) {
  float vZ = cos(angleV) * sin(angleH);
  float lookZ = camZ + vZ * delta;
  return lookZ;
}
float vectorY() {
  float vY = sin(angleV);
  float lookY = camY + vY;
  return lookY;
}
boolean isHit_H() {
  for (int i = 0; i<360; i+=10) {
    if (map[round((cos(radians(i))*0.2 + nextralX))][round((sin(radians(i))*0.2 + nextralZ))][round(nextY)-1]>=10)return true;
    if (map[round((cos(radians(i))*0.2 + nextralX))][round((sin(radians(i))*0.2 + nextralZ))][round(nextY)+0]>=10)return true;
  }
  return false;
}
boolean isHit_V() {
  for (int i = 0; i<360; i+=10) {
    if (map[round((cos(radians(i))*0.330 + nextX))][round((sin(radians(i))*0.330 + nextZ))][round(nextY-2)]>=10)return true;
  }
  return false;
}
boolean can_i_jump() {
  if (map[round(camX)][round(camZ)][round(camY-2)]==0) return false;
  for (int i = 0; i<360; i+=10) {
    if (map[round((cos(radians(i))*0.335 + nextX))][round((sin(radians(i))*0.335 + nextZ))][round(nextY+1)]>=10)return false;
  }
  return true;
}
boolean inWater() {
  if (map[round(camX)][round(camZ)][round(camY-2)]!=0&&map[round(camX)][round(camZ)][round(camY-2)]<10) return true;
  else return false;
}
boolean inWater_eye() {
  if (map[round(camX)][round(camZ)][round(camY+0.25)]!=0&&map[round(camX)][round(camZ)][round(camY+0.25)]<10) return true;
  else return false;
}
int onBlock() {
  return map[round(camX)][round(camZ)][round(camY-2)];
}
FocusBlock_and_PuttablePosition focusBlock_and_puttablePosition() {
  float lineX = camX, lineZ = camZ, lineY = camY;
  float directionX = cos(angleV) * cos(angleH);
  float directionY = sin(angleV);
  float directionZ = cos(angleV) * sin(angleH);
  for (int i = 0; i < 50; i++) {
    lineX += directionX * stride;
    lineY += directionY * stride;
    lineZ += directionZ * stride;
    int targetX = round(lineX);
    int targetY = round(lineY);
    int targetZ = round(lineZ);
    if (targetX >= 0 && targetX < worldX && targetY >= 0 && targetY < worldY && targetZ >= 0 && targetZ < worldZ && map[targetX][targetZ][targetY] >= 10) return new FocusBlock_and_PuttablePosition(true, targetX, targetZ, targetY, round(lineX - directionX * stride), round(lineZ - directionZ * stride), round(lineY - directionY * stride));
  }
  return new FocusBlock_and_PuttablePosition(false, 0, 0, 0, 0, 0, 0);
}
boolean isSame() {
  if (focusBlock_and_puttablePosition.Fx==PfocusBlock_and_puttablePosition.Fx&&focusBlock_and_puttablePosition.Fz==PfocusBlock_and_puttablePosition.Fz&&focusBlock_and_puttablePosition.Fy==PfocusBlock_and_puttablePosition.Fy) return true;
  else return false;
}
boolean can_i_draw_this_chunk(int i, int j, int k) {
  float distance = dist(vectorX(16), vectorZ(16), camY, i*chunkSize+chunkSize/2, j*chunkSize+chunkSize/2, k*chunkSize+chunkSize/2);
  return distance <= MAX_view_distance;
}
void Draw_Block(int x, int z, int y, int block_num) {
  PImage texture = block_data[block_num].block_img;

  boolean centerFrame = map[x][z+1][y] < 10;
  boolean backFrame = map[x][z-1][y] < 10;
  boolean leftFrame = map[x-1][z][y] < 10;
  boolean rightFrame = map[x+1][z][y] < 10;
  if (block_num == 32) fill(#338627);

  // 固定スケールの値
  float halfSize = 0.5;

  pushMatrix();
  translate(x, y, z);
  beginShape(QUADS);
  texture(texture);

  // 前面
  if (centerFrame) {
    vertex(-halfSize, -halfSize, halfSize, 0, 0);
    vertex(halfSize, -halfSize, halfSize, texture.width, 0);
    vertex(halfSize, halfSize, halfSize, texture.width, texture.height);
    vertex(-halfSize, halfSize, halfSize, 0, texture.height);
  }
  // 背面
  if (backFrame) {
    vertex(-halfSize, -halfSize, -halfSize, 0, 0);
    vertex(-halfSize, halfSize, -halfSize, 0, texture.height);
    vertex(halfSize, halfSize, -halfSize, texture.width, texture.height);
    vertex(halfSize, -halfSize, -halfSize, texture.width, 0);
  }
  // 左側面
  if (leftFrame) {
    vertex(-halfSize, -halfSize, -halfSize, 0, 0);
    vertex(-halfSize, -halfSize, halfSize, texture.width, 0);
    vertex(-halfSize, halfSize, halfSize, texture.width, texture.height);
    vertex(-halfSize, halfSize, -halfSize, 0, texture.height);
  }
  // 右側面
  if (rightFrame) {
    vertex(halfSize, -halfSize, -halfSize, 0, 0);
    vertex(halfSize, halfSize, -halfSize, 0, texture.height);
    vertex(halfSize, halfSize, halfSize, texture.width, texture.height);
    vertex(halfSize, -halfSize, halfSize, texture.width, 0);
  }
  // 底面
  if (y > 0) {
    if (map[x][z][y-1] < 10) {
      vertex(-halfSize, -halfSize, -halfSize, 0, 0);
      vertex(halfSize, -halfSize, -halfSize, texture.width, 0);
      vertex(halfSize, -halfSize, halfSize, texture.width, texture.height);
      vertex(-halfSize, -halfSize, halfSize, 0, texture.height);
    }
  }
  // 上面
  if (y < worldY) {
    if (map[x][z][y+1] < 10) {
      vertex(-halfSize, halfSize, -halfSize, 0, 0);
      vertex(-halfSize, halfSize, halfSize, 0, texture.height);
      vertex(halfSize, halfSize, halfSize, texture.width, texture.height);
      vertex(halfSize, halfSize, -halfSize, texture.width, 0);
    }
  }

  endShape();
  popMatrix();
  fill(255);
}
void Draw_Block2(int x, int z, int y, int block_num) {
  fill(255);
  PImage texture = block_data[block_num].block_img;
  if (x>0&&y>0&&x<worldX&&z<worldZ) {
    boolean centerFrame = map[x][z+1][y]<10;
    boolean backFrame = map[x][z-1][y]<10;
    boolean leftFrame = map[x-1][z][y]<10;
    boolean rightFrame = map[x+1][z][y]<10;
    pushMatrix();
    translate(x, y, z);
    beginShape(QUADS);
    texture(texture);
    // 前面
    if (centerFrame) {
      vertex(-0.5, -0.5, 0.5, 0, 0);
      vertex(0.5, -0.5, 0.5, texture.width, 0);
      vertex(0.5, 0.5, 0.5, texture.width, texture.height);
      vertex(-0.5, 0.5, 0.5, 0, texture.height);
    }
    // 背面
    if (backFrame) {
      vertex(-0.5, -0.5, -0.5, 0, 0);
      vertex(-0.5, 0.5, -0.5, 0, texture.height);
      vertex(0.5, 0.5, -0.5, texture.width, texture.height);
      vertex(0.5, -0.5, -0.5, texture.width, 0);
    }
    // 左側面
    if (leftFrame) {
      vertex(-0.5, -0.5, -0.5, 0, 0);
      vertex(-0.5, -0.5, 0.5, texture.width, 0);
      vertex(-0.5, 0.5, 0.5, texture.width, texture.height);
      vertex(-0.5, 0.5, -0.5, 0, texture.height);
    }
    // 右側面
    if (rightFrame) {
      vertex(0.5, -0.5, -0.5, 0, 0);
      vertex(0.5, 0.5, -0.5, 0, texture.height);
      vertex(0.5, 0.5, 0.5, texture.width, texture.height);
      vertex(0.5, -0.5, 0.5, texture.width, 0);
    }
    endShape();
    popMatrix();
  }
  if (y>0) {
    if (map[x][z][y-1]<10) {
      pushMatrix();
      translate(x, y, z);
      beginShape(QUADS);
      texture = block_data[block_num].block_img2;
      texture(texture);
      // 上面
      vertex(-0.5, -0.5, -0.5, 0, 0);
      vertex(0.5, -0.5, -0.5, texture.width, 0);
      vertex(0.5, -0.5, 0.5, texture.width, texture.height);
      vertex(-0.5, -0.5, 0.5, 0, texture.height);
      endShape();
      popMatrix();
    }
  }
  if (y<worldY) {
    if (map[x][z][y+1]<10) {
      pushMatrix();
      translate(x, y, z);
      beginShape(QUADS);
      texture = block_data[block_num].block_img2;
      texture(texture);
      // 底面
      vertex(-0.5, 0.5, -0.5, 0, 0);
      vertex(-0.5, 0.5, 0.5, 0, texture.height);
      vertex(0.5, 0.5, 0.5, texture.width, texture.height);
      vertex(0.5, 0.5, -0.5, texture.width, 0);
      endShape();
      popMatrix();
    }
  }
}
void Draw_Block3(int x, int z, int y, int block_num) {
  PImage texture = block_data[block_num].block_img;
  if (x>0&&y>0&&x<worldX&&z<worldZ) {
    boolean centerFrame = map[x][z+1][y]<10;
    boolean backFrame = map[x][z-1][y]<10;
    boolean leftFrame = map[x-1][z][y]<10;
    boolean rightFrame = map[x+1][z][y]<10;
    pushMatrix();
    translate(x, y, z);
    beginShape(QUADS);
    texture(texture);
    // 前面
    if (centerFrame) {
      vertex(-0.5, -0.5, 0.5, 0, 0);
      vertex(0.5, -0.5, 0.5, texture.width, 0);
      vertex(0.5, 0.5, 0.5, texture.width, texture.height);
      vertex(-0.5, 0.5, 0.5, 0, texture.height);
    }
    // 背面
    if (backFrame) {
      vertex(-0.5, -0.5, -0.5, 0, 0);
      vertex(-0.5, 0.5, -0.5, 0, texture.height);
      vertex(0.5, 0.5, -0.5, texture.width, texture.height);
      vertex(0.5, -0.5, -0.5, texture.width, 0);
    }
    // 左側面
    if (leftFrame) {
      vertex(-0.5, -0.5, -0.5, 0, 0);
      vertex(-0.5, -0.5, 0.5, texture.width, 0);
      vertex(-0.5, 0.5, 0.5, texture.width, texture.height);
      vertex(-0.5, 0.5, -0.5, 0, texture.height);
    }
    // 右側面
    if (rightFrame) {
      vertex(0.5, -0.5, -0.5, 0, 0);
      vertex(0.5, 0.5, -0.5, 0, texture.height);
      vertex(0.5, 0.5, 0.5, texture.width, texture.height);
      vertex(0.5, -0.5, 0.5, texture.width, 0);
    }
    endShape();
    popMatrix();
  }
  if (camY<worldY) {
    if (map[x][z][y-1]<10) {
      pushMatrix();
      translate(x, y, z);
      beginShape(QUADS);
      texture = block_data[block_num].block_img2;
      texture(texture);
      // 底面
      vertex(-0.5, -0.5, -0.5, 0, 0);
      vertex(0.5, -0.5, -0.5, texture.width, 0);
      vertex(0.5, -0.5, 0.5, texture.width, texture.height);
      vertex(-0.5, -0.5, 0.5, 0, texture.height);
      endShape();
      popMatrix();
    }
  }
  if (y>0) {
    if (map[x][z][y+1]<10) {
      fill(#33C934);
      pushMatrix();
      translate(x, y, z);
      beginShape(QUADS);
      texture = block_data[block_num].block_img3;
      texture(texture);
      // 上面
      vertex(-0.5, 0.5, -0.5, 0, 0);
      vertex(-0.5, 0.5, 0.5, 0, texture.height);
      vertex(0.5, 0.5, 0.5, texture.width, texture.height);
      vertex(0.5, 0.5, -0.5, texture.width, 0);
      endShape();
      popMatrix();
    }
  }
  fill(255, 255, 255);
}
void Draw_Water(int x, int z, int y, int block_num) {
  PImage texture = water;
  float A1_difference = (7.0-block_num)/7.0;
  float A2_difference = (7.0-block_num)/7.0;
  float A3_difference = (7.0-block_num)/7.0;
  float A4_difference = (7.0-block_num)/7.0;
  if (map[x][z+1][y]<10) {
    A1_difference += (map[x][z+1][y]-block_num)/14.0;
    A2_difference += (map[x][z+1][y]-block_num)/14.0;
  }
  if (map[x+1][z][y]<10) {
    A2_difference += (map[x+1][z][y]-block_num)/14.0;
    A3_difference += (map[x+1][z][y]-block_num)/14.0;
  }
  if (map[x][z-1][y]<10) {
    A3_difference += (map[x][z-1][y]-block_num)/14.0;
    A4_difference += (map[x][z-1][y]-block_num)/14.0;
  }
  if (map[x-1][z][y]<10) {
    A4_difference += (map[x-1][z][y]-block_num)/14.0;
    A1_difference += (map[x-1][z][y]-block_num)/14.0;
  }
  float temp_A1 = A1_difference;
  float temp_A2 = A2_difference;
  float temp_A3 = A3_difference;
  float temp_A4 = A4_difference;
  if (temp_A1 == temp_A2) {
    A1_difference += 1 / 7.0;
    A2_difference += 1 / 7.0;
  }
  if (temp_A2 == temp_A3) {
    A2_difference += 1 / 7.0;
    A3_difference += 1 / 7.0;
  }
  if (temp_A3 == temp_A4) {
    A3_difference += 1 / 7.0;
    A4_difference += 1 / 7.0;
  }
  if (temp_A4 == temp_A1) {
    A4_difference += 1 / 7.0;
    A1_difference += 1 / 7.0;
  }
  fill(#2634ad, 200);
  pushMatrix();
  translate(x, y, z);
  beginShape(QUADS);
  texture(texture);
  if (map[x][z][y+1]==0) {
    vertex(-0.5, 0.5-A2_difference, -0.5, 0, 0);
    vertex(-0.5, 0.5-A3_difference, 0.5, 0, texture.height);
    vertex(0.5, 0.5-A4_difference, 0.5, texture.width, texture.height);
    vertex(0.5, 0.5-A1_difference, -0.5, texture.width, 0);
  }
  endShape();
  popMatrix();
  fill(255);
}
void DeleteEffect(float x, float z, float y, int deleteLevel) {
  PImage texture = delete_level[18-(deleteLevel/6)]; // 使用するテクスチャ
  pushMatrix();
  translate(x, y, z);
  beginShape(QUADS);
  texture(texture);
  // 前面
  vertex(-0.5, -0.5, 0.5, 0, 0);
  vertex(0.5, -0.5, 0.5, texture.width, 0);
  vertex(0.5, 0.5, 0.5, texture.width, texture.height);
  vertex(-0.5, 0.5, 0.5, 0, texture.height);
  // 背面
  vertex(-0.5, -0.5, -0.5, 0, 0);
  vertex(-0.5, 0.5, -0.5, 0, texture.height);
  vertex(0.5, 0.5, -0.5, texture.width, texture.height);
  vertex(0.5, -0.5, -0.5, texture.width, 0);
  // 左側面
  vertex(-0.5, -0.5, -0.5, 0, 0);
  vertex(-0.5, -0.5, 0.5, texture.width, 0);
  vertex(-0.5, 0.5, 0.5, texture.width, texture.height);
  vertex(-0.5, 0.5, -0.5, 0, texture.height);
  // 右側面
  vertex(0.5, -0.5, -0.5, 0, 0);
  vertex(0.5, 0.5, -0.5, 0, texture.height);
  vertex(0.5, 0.5, 0.5, texture.width, texture.height);
  vertex(0.5, -0.5, 0.5, texture.width, 0);
  // 上面
  vertex(-0.5, -0.5, -0.5, 0, 0);
  vertex(0.5, -0.5, -0.5, texture.width, 0);
  vertex(0.5, -0.5, 0.5, texture.width, texture.height);
  vertex(-0.5, -0.5, 0.5, 0, texture.height);
  // 底面
  vertex(-0.5, 0.5, -0.5, 0, 0);
  vertex(-0.5, 0.5, 0.5, 0, texture.height);
  vertex(0.5, 0.5, 0.5, texture.width, texture.height);
  vertex(0.5, 0.5, -0.5, texture.width, 0);
  endShape();
  popMatrix();
}
void Draw_DroppedItem(float x, float z, float y, int block_num, float scale, int rotate) {
  PImage texture = block_data[block_num].block_img;
  pushMatrix();
  translate(x, y, z);
  beginShape(QUADS);
  texture(texture);
  if (rotate!=0)rotateY(radians(rotate));
  // 前面
  vertex(-scale * 0.5, -scale * 0.5, scale * 0.5, 0, 0);
  vertex(scale * 0.5, -scale * 0.5, scale * 0.5, texture.width, 0);
  vertex(scale * 0.5, scale * 0.5, scale * 0.5, texture.width, texture.height);
  vertex(-scale * 0.5, scale * 0.5, scale * 0.5, 0, texture.height);
  // 背面
  vertex(-scale * 0.5, -scale * 0.5, -scale * 0.5, 0, 0);
  vertex(-scale * 0.5, scale * 0.5, -scale * 0.5, 0, texture.height);
  vertex(scale * 0.5, scale * 0.5, -scale * 0.5, texture.width, texture.height);
  vertex(scale * 0.5, -scale * 0.5, -scale * 0.5, texture.width, 0);
  // 左側面
  vertex(-scale * 0.5, -scale * 0.5, -scale * 0.5, 0, 0);
  vertex(-scale * 0.5, -scale * 0.5, scale * 0.5, texture.width, 0);
  vertex(-scale * 0.5, scale * 0.5, scale * 0.5, texture.width, texture.height);
  vertex(-scale * 0.5, scale * 0.5, -scale * 0.5, 0, texture.height);
  // 右側面
  vertex(scale * 0.5, -scale * 0.5, -scale * 0.5, 0, 0);
  vertex(scale * 0.5, scale * 0.5, -scale * 0.5, 0, texture.height);
  vertex(scale * 0.5, scale * 0.5, scale * 0.5, texture.width, texture.height);
  vertex(scale * 0.5, -scale * 0.5, scale * 0.5, texture.width, 0);
  // 上面
  vertex(-scale * 0.5, -scale * 0.5, -scale * 0.5, 0, 0);
  vertex(scale * 0.5, -scale * 0.5, -scale * 0.5, texture.width, 0);
  vertex(scale * 0.5, -scale * 0.5, scale * 0.5, texture.width, texture.height);
  vertex(-scale * 0.5, -scale * 0.5, scale * 0.5, 0, texture.height);
  // 底面
  vertex(-scale * 0.5, scale * 0.5, -scale * 0.5, 0, 0);
  vertex(-scale * 0.5, scale * 0.5, scale * 0.5, 0, texture.height);
  vertex(scale * 0.5, scale * 0.5, scale * 0.5, texture.width, texture.height);
  vertex(scale * 0.5, scale * 0.5, -scale * 0.5, texture.width, 0);

  endShape();
  popMatrix();
}
void Draw_DroppedItem2(float x, float z, float y, int block_num, float scale, int rotate) {
  fill(255);
  PImage texture = block_data[block_num].block_img;
  pushMatrix();
  translate(x, y, z);
  beginShape(QUADS);
  texture(texture);
  if (rotate!=0)rotateY(radians(rotate));
  // 前面
  vertex(-scale * 0.5, -scale * 0.5, scale * 0.5, 0, 0);
  vertex(scale * 0.5, -scale * 0.5, scale * 0.5, texture.width, 0);
  vertex(scale * 0.5, scale * 0.5, scale * 0.5, texture.width, texture.height);
  vertex(-scale * 0.5, scale * 0.5, scale * 0.5, 0, texture.height);
  // 背面
  vertex(-scale * 0.5, -scale * 0.5, -scale * 0.5, 0, 0);
  vertex(-scale * 0.5, scale * 0.5, -scale * 0.5, 0, texture.height);
  vertex(scale * 0.5, scale * 0.5, -scale * 0.5, texture.width, texture.height);
  vertex(scale * 0.5, -scale * 0.5, -scale * 0.5, texture.width, 0);
  // 左側面
  vertex(-scale * 0.5, -scale * 0.5, -scale * 0.5, 0, 0);
  vertex(-scale * 0.5, -scale * 0.5, scale * 0.5, texture.width, 0);
  vertex(-scale * 0.5, scale * 0.5, scale * 0.5, texture.width, texture.height);
  vertex(-scale * 0.5, scale * 0.5, -scale * 0.5, 0, texture.height);
  // 右側面
  vertex(scale * 0.5, -scale * 0.5, -scale * 0.5, 0, 0);
  vertex(scale * 0.5, scale * 0.5, -scale * 0.5, 0, texture.height);
  vertex(scale * 0.5, scale * 0.5, scale * 0.5, texture.width, texture.height);
  vertex(scale * 0.5, -scale * 0.5, scale * 0.5, texture.width, 0);

  endShape();
  popMatrix();

  pushMatrix();
  translate(x, y, z);
  beginShape(QUADS);
  texture = block_data[block_num].block_img2;
  texture(texture);
  if (rotate!=0)rotateY(radians(rotate));
  // 上面
  vertex(-scale * 0.5, -scale * 0.5, -scale * 0.5, 0, 0);
  vertex(scale * 0.5, -scale * 0.5, -scale * 0.5, texture.width, 0);
  vertex(scale * 0.5, -scale * 0.5, scale * 0.5, texture.width, texture.height);
  vertex(-scale * 0.5, -scale * 0.5, scale * 0.5, 0, texture.height);
  // 底面
  vertex(-scale * 0.5, scale * 0.5, -scale * 0.5, 0, 0);
  vertex(-scale * 0.5, scale * 0.5, scale * 0.5, 0, texture.height);
  vertex(scale * 0.5, scale * 0.5, scale * 0.5, texture.width, texture.height);
  vertex(scale * 0.5, scale * 0.5, -scale * 0.5, texture.width, 0);

  endShape();
  popMatrix();
}
void Draw_DroppedItem3(float x, float z, float y, int block_num, float scale, int rotate) {
  fill(255);
  PImage texture = block_data[block_num].block_img;
  pushMatrix();
  translate(x, y, z);
  beginShape(QUADS);
  texture(texture);
  if (rotate!=0)rotateY(radians(rotate));
  // 前面
  vertex(-scale * 0.5, -scale * 0.5, scale * 0.5, 0, 0);
  vertex(scale * 0.5, -scale * 0.5, scale * 0.5, texture.width, 0);
  vertex(scale * 0.5, scale * 0.5, scale * 0.5, texture.width, texture.height);
  vertex(-scale * 0.5, scale * 0.5, scale * 0.5, 0, texture.height);
  // 背面
  vertex(-scale * 0.5, -scale * 0.5, -scale * 0.5, 0, 0);
  vertex(-scale * 0.5, scale * 0.5, -scale * 0.5, 0, texture.height);
  vertex(scale * 0.5, scale * 0.5, -scale * 0.5, texture.width, texture.height);
  vertex(scale * 0.5, -scale * 0.5, -scale * 0.5, texture.width, 0);
  // 左側面
  vertex(-scale * 0.5, -scale * 0.5, -scale * 0.5, 0, 0);
  vertex(-scale * 0.5, -scale * 0.5, scale * 0.5, texture.width, 0);
  vertex(-scale * 0.5, scale * 0.5, scale * 0.5, texture.width, texture.height);
  vertex(-scale * 0.5, scale * 0.5, -scale * 0.5, 0, texture.height);
  // 右側面
  vertex(scale * 0.5, -scale * 0.5, -scale * 0.5, 0, 0);
  vertex(scale * 0.5, scale * 0.5, -scale * 0.5, 0, texture.height);
  vertex(scale * 0.5, scale * 0.5, scale * 0.5, texture.width, texture.height);
  vertex(scale * 0.5, -scale * 0.5, scale * 0.5, texture.width, 0);

  endShape();
  popMatrix();

  pushMatrix();
  translate(x, y, z);
  beginShape(QUADS);
  texture = block_data[block_num].block_img2;
  texture(texture);
  if (rotate!=0)rotateY(radians(rotate));
  // 上面
  vertex(-scale * 0.5, -scale * 0.5, -scale * 0.5, 0, 0);
  vertex(scale * 0.5, -scale * 0.5, -scale * 0.5, texture.width, 0);
  vertex(scale * 0.5, -scale * 0.5, scale * 0.5, texture.width, texture.height);
  vertex(-scale * 0.5, -scale * 0.5, scale * 0.5, 0, texture.height);

  endShape();
  popMatrix();

  pushMatrix();
  translate(x, y, z);
  beginShape(QUADS);
  texture = block_data[block_num].block_img3;
  texture(texture);
  // 底面
  vertex(-scale * 0.5, scale * 0.5, -scale * 0.5, 0, 0);
  vertex(-scale * 0.5, scale * 0.5, scale * 0.5, 0, texture.height);
  vertex(scale * 0.5, scale * 0.5, scale * 0.5, texture.width, texture.height);
  vertex(scale * 0.5, scale * 0.5, -scale * 0.5, texture.width, 0);

  endShape();
  popMatrix();
}
void Draw_DroppedItem6(float x, float z, float y, int block_num, float scale, int rotate) {
  PImage texture = block_data[block_num].block_img;
  pushMatrix();
  translate(x, y, z);
  beginShape(QUADS);
  texture(texture);
  if (rotate != 0) rotateY(radians(rotate));

  // 表面を描画
  vertex(-scale * 0.5, -scale * 0.5, 0, 0, 0);
  vertex(scale * 0.5, -scale * 0.5, 0, texture.width, 0);
  vertex(scale * 0.5, scale * 0.5, 0, texture.width, texture.height);
  vertex(-scale * 0.5, scale * 0.5, 0, 0, texture.height);

  // 裏面を描画（UV座標は反転させる）
  vertex(-scale * 0.5, -scale * 0.5, 0, 0, 0);
  vertex(-scale * 0.5, scale * 0.5, 0, 0, texture.height);
  vertex(scale * 0.5, scale * 0.5, 0, texture.width, texture.height);
  vertex(scale * 0.5, -scale * 0.5, 0, texture.width, 0);
  endShape();
  popMatrix();
}

// ホットバー描画
void hotBar() {
  PImage item_img = null;
  textSize(20);
  noStroke();
  fill(0);

  rect(width/2-408, 996, 728, 88);//陰影
  stroke(100, 100, 100, 200);
  strokeWeight(10);
  for (int i = 0; i<9; i++) {
    if (i==hothotItem)fill(180, 255);
    else fill(130, 255);

    rect(i*80+width /2-400, 1004, 70, 70);
    if (item[i] != null) {
      item_img = block_data[item[i].item_num].block_img;
      image(item_img, i*80+width/2-387, 1015, 46, 46);
      fill(255, 255, 255);
      text(int(item[i].amount), i*80+width/2-360, 1060);
    }
  }
  strokeWeight(1);
  noStroke();
}
// インベントリ
void Inventory() {
  PImage item_img = null;
  stroke(0);
  fill(0);
  rect(width / 2 - 248, height / 2 - 248, 400, 400, 10);
  fill(180);
  rect(width / 2 - 250, height / 2 - 250, 400, 400, 10);
  textSize(14);

  // ホットバー部
  for (int i = 0; i < 9; i++) {
    fill(130);
    rect(width / 2 - 240 + i * 42, height / 2 + 100, 40, 40);
    if (item[i] != null) {
      item_img = block_data[item[i].item_num].block_img;
      fill(255);
      image(item_img, width / 2 - 236 + i * 42, height / 2 + 104, 32, 32);
      text(item[i].amount, width / 2 - 212 + i * 42, height / 2 + 135);
    }
    if (mouseReleased) {
      // 左の当たり判定は
      if (mouseX > width / 2 - 236 + i * 42 && mouseX < width / 2 - 204 + i * 42 &&mouseY > height / 2 + 104 && mouseY < height / 2 + 146 &&mousePressed && mouseButton == LEFT) {
        //ホットアイテムあるときー
        if (hotItem != null) {
          //アイテム代入のとこにアイテムがないときー
          if (item[i] == null) {
            item[i] = new Item(hotItem.item_num, hotItem.amount);
            hotItem = null;
          }
          //アイテム代入のとこにアイテムがあるときー
          else {
            // ホットアイテムとアイテムが一緒なときー
            if (hotItem.item_num == item[i].item_num) {
              // 合計は64こえるとき
              if (hotItem.amount+item[i].amount >= 64) {
                item[i].amount = 64;
                hotItem.amount = abs(hotItem.amount-item[i].amount);
                if (hotItem.amount==0) hotItem = null;
              } else {
                item[i].amount = hotItem.amount+item[i].amount;
                hotItem = null;
              }
            }
            // ホットアイテムとアイテムが一緒じゃないときー
            else {
              Item Pitem;
              Pitem = new Item(hotItem.item_num, hotItem.amount);
              hotItem = new Item(item[i].item_num, item[i].amount);
              item[i] = new Item(Pitem.item_num, Pitem.amount);
            }
          }
        }
        //ホットアイテムないときー
        else {
          if (item[i] != null) {
            hotItem = new Item(item[i].item_num, item[i].amount);
            item[i] = null;
          }
        }
      }
      // ここまで
      // 右の当たり判定は
      if (mouseX > width / 2 - 236 + i * 42 && mouseX < width / 2 - 204 + i * 42 &&mouseY > height / 2 + 104 && mouseY < height / 2 + 146 &&mousePressed && mouseButton == RIGHT) {
        //ホットアイテムあるときー
        if (hotItem != null) {
          //アイテム代入のとこにアイテムがないときー
          if (item[i] == null) {
            item[i] = new Item(hotItem.item_num, 1);
            hotItem.amount--;
            if (hotItem.amount==0) hotItem = null;
          }
          //アイテム代入のとこにアイテムがあるときー
          else {
            //代入するアイテムが一緒なときー
            if (hotItem.item_num == item[i].item_num) {
              if (item[i].amount<64&&hotItem.amount>0) {
                item[i].amount++;
                hotItem.amount--;
                if (hotItem.amount==0) hotItem = null;
              }
            }
          }
        }
      }
    }
  }
  // 内部インベントリ部
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 3; j++) {
      fill(130);
      rect(width / 2 + i * 42 - 240, height / 2 + j * 42 - 50, 40, 40);
      if (item[i + j * 9 + 9] != null) {
        fill(255);
        item_img = block_data[item[i + j * 9 + 9].item_num].block_img;
        image(item_img, width / 2 + i * 42 - 240+4, height / 2 + j * 42 - 50+4, 32, 32);
        text(item[i + j * 9 + 9].amount, width / 2 - 212 + i * 42, height / 2 - 15 + j * 42);
      }
      if (mouseReleased) {
        // 左の当たり判定は
        if (mouseX > width / 2 - 240 + i * 42 && mouseX < width / 2 - 200 + i * 42 &&mouseY > height / 2 + j * 42 - 46 && mouseY < height / 2 + j * 42 - 4 &&mousePressed && mouseButton == LEFT) {
          //ホットアイテムあるときー
          if (hotItem != null) {
            //アイテム代入のとこにアイテムがないときー
            if (item[i + j * 9 + 9] == null) {
              item[i + j * 9 + 9] = new Item(hotItem.item_num, hotItem.amount);
              hotItem = null;
            }
            //アイテム代入のとこにアイテムがあるときー
            else {
              // ホットアイテムとアイテムが一緒なときー
              if (hotItem.item_num == item[i + j * 9 + 9].item_num) {
                // 合計は64こえるとき
                if (hotItem.amount+item[i + j * 9 + 9].amount >= 64) {
                  item[i + j * 9 + 9].amount = 64;
                  hotItem.amount = abs(hotItem.amount-item[i + j * 9 + 9].amount);
                  if (hotItem.amount==0) hotItem = null;
                } else {
                  item[i + j * 9 + 9].amount = hotItem.amount+item[i + j * 9 + 9].amount;
                  hotItem = null;
                }
              }
              // ホットアイテムとアイテムが一緒じゃないときー
              else {
                Item Pitem;
                Pitem = new Item(hotItem.item_num, hotItem.amount);
                hotItem = new Item(item[i + j * 9 + 9].item_num, item[i + j * 9 + 9].amount);
                item[i + j * 9 + 9] = new Item(Pitem.item_num, Pitem.amount);
              }
            }
          }
          //ホットアイテムないときー
          else {
            if (item[i + j * 9 + 9] == null) {
            } else {
              hotItem = new Item(item[i + j * 9 + 9].item_num, item[i + j * 9 + 9].amount);
              item[i + j * 9 + 9] = null;
            }
          }
        }
        // ここまで
        // 右の当たり判定は
        if (mouseX > width / 2 - 240 + i * 42 && mouseX < width / 2 - 200 + i * 42 &&mouseY > height / 2 + j * 42 - 46 && mouseY < height / 2 + j * 42 - 4 &&mousePressed && mouseButton == RIGHT) {
          //ホットアイテムあるときー
          if (hotItem != null) {
            //アイテム代入のとこにアイテムがないときー
            if (item[i + j * 9 + 9] == null) {
              item[i + j * 9 + 9] = new Item(hotItem.item_num, 1);
              hotItem.amount--;
              if (hotItem.amount==0) hotItem = null;
            }
            //アイテム代入のとこにアイテムがあるときー
            else {
              //代入するアイテムが一緒なときー
              if (hotItem.item_num == item[i + j * 9 + 9].item_num) {
                if (item[i + j * 9 + 9].amount<64&&hotItem.amount>0) {
                  item[i + j * 9 + 9].amount++;
                  hotItem.amount--;
                  if (hotItem.amount==0) hotItem = null;
                }
              }
            }
          }
        }
      }
    }
  }
  // クラフト部
  for (int i  =0; i<3; i++) {
    for (int j =0; j<3; j++) {
      fill(130);
      rect(width / 2 + i * 42 - 200, height / 2 + j * 42 - 210, 40, 40);
      if (craftItem[i][j] != null) {
        item_img = block_data[craftItem[i][j].item_num].block_img;
        fill(255);
        image(item_img, width / 2  + i * 42 - 200+4, height / 2 + j * 42 - 210+4, 32, 32);
        text(craftItem[i][j].amount, width / 2  + i * 42 - 200 +31, height / 2 + j * 42 - 210 +31);
      }
      if (mouseReleased) {
        // 左の当たり判定は
        if (mouseX > width / 2 + i * 42 - 200&& mouseX < width / 2 + i * 42 - 200 +42 &&mouseY > height / 2 + j * 42 - 210 && mouseY < height / 2 + j * 42 - 210 +42 &&mousePressed && mouseButton == LEFT) {
          //ホットアイテムあるときー
          if (hotItem != null) {
            //アイテム代入のとこにアイテムがないときー
            if (craftItem[i][j] == null) {
              craftItem[i][j] = new Item(hotItem.item_num, hotItem.amount);
              hotItem = null;
            }
            //アイテム代入のとこにアイテムがあるときー
            else {
              // ホットアイテムとアイテムが一緒なときー
              if (hotItem.item_num == craftItem[i][j].item_num) {
                // 合計は64こえるとき
                if (hotItem.amount+craftItem[i][j].amount >= 64) {
                  craftItem[i][j].amount = 64;
                  hotItem.amount = abs(hotItem.amount-craftItem[i][j].amount);
                  if (hotItem.amount==0) hotItem = null;
                } else {
                  craftItem[i][j].amount = hotItem.amount+craftItem[i][j].amount;
                  hotItem = null;
                }
              }
              // ホットアイテムとアイテムが一緒じゃないときー
              else {
                Item Pitem;
                Pitem = new Item(hotItem.item_num, hotItem.amount);
                hotItem = new Item(craftItem[i][j].item_num, craftItem[i][j].amount);
                craftItem[i][j] = new Item(Pitem.item_num, Pitem.amount);
              }
            }
          }
          //ホットアイテムないときー
          else {
            if (craftItem[i][j] == null) {
            } else {
              hotItem = new Item(craftItem[i][j].item_num, craftItem[i][j].amount);
              craftItem[i][j] = null;
            }
          }
        }
        // ここまで
        // 右の当たり判定は
        if (mouseX > width / 2 + i * 42 - 200&& mouseX < width / 2 + i * 42 - 200 +42 &&mouseY > height / 2 + j * 42 - 210 && mouseY < height / 2 + j * 42 - 210 +42 &&mousePressed && mouseButton == RIGHT) {
          //ホットアイテムあるときー
          if (hotItem != null) {
            //アイテム代入のとこにアイテムがないときー
            if (craftItem[i][j] == null) {
              craftItem[i][j] = new Item(hotItem.item_num, 1);
              hotItem.amount--;
              if (hotItem.amount==0) hotItem = null;
            }
            //アイテム代入のとこにアイテムがあるときー
            else {
              //代入するアイテムが一緒なときー
              if (hotItem.item_num == craftItem[i][j].item_num) {
                if (craftItem[i][j].amount<64&&hotItem.amount>0) {
                  craftItem[i][j].amount++;
                  hotItem.amount--;
                  if (hotItem.amount==0) hotItem = null;
                }
              }
            }
          }
        }
      }
    }
  }
  fill(130);
  triangle(width / 2-40, height / 2 - 155, width / 2-40, height / 2 - 135, width / 2-30, height / 2 - 145);
  // クラフト全探査
  boolean exitLoop = false;
  for (int i = 0; i< recipe.size(); i++) {
    for (int j =0; j<64/recipe.get(i).amount; j++) {
      if ((recipe.get(i).m1==0||(craftItem[0][0]!=null&&recipe.get(i).m1==craftItem[0][0].item_num&&craftItem[0][0].amount>=j))&&
        (recipe.get(i).m2==0||(craftItem[0][1]!=null&&recipe.get(i).m2==craftItem[0][1].item_num&&craftItem[0][1].amount>=j))&&
        (recipe.get(i).m3==0||(craftItem[0][2]!=null&&recipe.get(i).m3==craftItem[0][2].item_num&&craftItem[0][2].amount>=j))&&
        (recipe.get(i).m4==0||(craftItem[1][0]!=null&&recipe.get(i).m4==craftItem[1][0].item_num&&craftItem[1][0].amount>=j))&&
        (recipe.get(i).m5==0||(craftItem[1][1]!=null&&recipe.get(i).m5==craftItem[1][1].item_num&&craftItem[1][1].amount>=j))&&
        (recipe.get(i).m6==0||(craftItem[1][2]!=null&&recipe.get(i).m6==craftItem[1][2].item_num&&craftItem[1][2].amount>=j))&&
        (recipe.get(i).m7==0||(craftItem[2][0]!=null&&recipe.get(i).m7==craftItem[2][0].item_num&&craftItem[2][0].amount>=j))&&
        (recipe.get(i).m8==0||(craftItem[2][1]!=null&&recipe.get(i).m8==craftItem[2][1].item_num&&craftItem[2][1].amount>=j))&&
        (recipe.get(i).m9==0||(craftItem[2][2]!=null&&recipe.get(i).m9==craftItem[2][2].item_num&&craftItem[2][2].amount>=j))) {
        craftedItem = new Item(recipe.get(i).item_num, j*recipe.get(i).amount);
        exitLoop = true;
      } else {
        if (exitLoop) break;
        if (j==0)craftedItem=null;
        break;
      }
    }
  }
  // 完成部
  rect(width / 2, height / 2 + 42 - 210, 40, 40);
  if (craftedItem != null) {
    item_img = block_data[craftedItem.item_num].block_img;
    fill(255);
    image(item_img, width / 2 +4, height / 2 + 42 - 210+4, 32, 32);
    text(craftedItem.amount, width / 2 + 31, height / 2 + 42 - 210+4+27);
  }
  // 左の当たり判定は
  if (mouseX > width / 2 +4&& mouseX < width / 2 +4 + 42 &&mouseY > height / 2 + 42 - 210+4 && mouseY <height / 2 + 42 - 210+4 +42 &&mousePressed && mouseButton == LEFT) {
    if (hotItem == null&&craftedItem != null) {
      int min = 64;
      for (int i = 0; i < 9; i++) {
        if ( craftItem[i/3][i%3]!=null) min = min(min, craftItem[i/3][i%3].amount);
      }
      for (int i =0; i <9; i++) {
        if ( craftItem[i/3][i%3]!=null) {
          craftItem[i/3][i%3].amount = craftItem[i/3][i%3].amount-min;
          if (craftItem[i/3][i%3].amount==0)craftItem[i/3][i%3] = null;
        }
      }
      hotItem = new Item(craftedItem.item_num, craftedItem.amount);
      craftedItem = null;
    }
  }
  // ここまで

  // 持ち運び中のアイテム描画
  if (hotItem != null) {
    fill(255, 255);
    item_img = block_data[hotItem.item_num].block_img;
    image(item_img, mouseX - 16, mouseY - 16, 32, 32);
    text(hotItem.amount, mouseX + 12, mouseY + 12);
  }
  noStroke();
}
void PutBlock(int x, int z, int y) {
  if (dist(camX, camZ, camY, x, z, y)>1&&item[hothotItem] != null&&item[hothotItem].item_num<100) {
    item[hothotItem].amount --;
    map[x][z][y]=item[hothotItem].item_num;
    if (item[hothotItem].amount == 0)item[hothotItem] = null;
  }
}
void keyPressed() {
  if (key < 256) {
    keys[key] = true;
  }
}
void keyReleased() {
  if (key < 256) {
    keys[key] = false;
  }
}
/*---------クラス--------*/
class FocusBlock_and_PuttablePosition {
  int Fx, Fz, Fy;
  int Px, Pz, Py;
  boolean bool;
  FocusBlock_and_PuttablePosition(boolean bool, int Fx, int Fz, int Fy, int Px, int Pz, int Py) {
    this.bool = bool;
    this.Fx = Fx;
    this.Fz = Fz;
    this.Fy = Fy;
    this.Px = Px;
    this.Pz = Pz;
    this.Py = Py;
  }
}
class DroppedItem {
  float x, y, z;
  int item_num;
  float velocity;
  int Rotate;
  DroppedItem(float x, float z, float y, int item_num) {
    this.x = x;
    this.z = z;
    this.y = y;
    this.item_num = item_num;
    this.velocity = 0;
    this.Rotate = 0;
  }
  void drawing() {
    Rotate ++;
    if (block_data[item_num].block_type==1)Draw_DroppedItem(x, z, y, item_num, 0.2, Rotate);
    if (block_data[item_num].block_type==2)Draw_DroppedItem2(x, z, y, item_num, 0.2, Rotate);
    if (block_data[item_num].block_type==6)Draw_DroppedItem6(x, z, y, item_num, 0.2, Rotate);

    //アイテムの落下計算
    if (map[round(x)][round(z)][round(y + gravity * 1.0 / frameRate-1)] == 0) {
      velocity -= gravity * 1.0 / frameRate;
      y += velocity * 1.0 / frameRate;
    } else {
      velocity = 0;
    }
  }
}
class Chunk {
  int offsetX, offsetZ, offsetY;
  int size;
  Chunk(int x, int z, int y, int s) {
    this.offsetX = x;
    this.offsetZ = z;
    this.offsetY = y;
    this.size = s;
  }
  public void drawing() {
    for (int x = offsetX; x < offsetX + size; x++) {
      for (int z = offsetZ; z < offsetZ + size; z++) {
        for (int y = offsetY; y < offsetY + size; y++) {
          switch (block_data[map[x][z][y]].block_type) {
          case 0:
            break;
          case 1:
            Draw_Block(x, z, y, map[x][z][y]);
            break;
          case 2:
            Draw_Block2(x, z, y, map[x][z][y]);
            break;
          case 3:
            Draw_Block3(x, z, y, map[x][z][y]);
            break;
          case 5:
            Draw_Water(x, z, y, map[x][z][y]);
            break;
          default:
            break;
          }
        }
      }
    }
  }
}
class BlockData {
  int block_type;
  PImage block_img;
  PImage block_img2;
  PImage block_img3;
  int block_softness;
  int block_change;
  BlockData(int block_type, PImage block_img, PImage block_img2, PImage block_img3, int block_softness, int block_change) {
    this.block_type = block_type;
    this.block_img = block_img;
    this.block_img2 = block_img2;
    this.block_img3 = block_img3;
    this.block_softness = block_softness;
    this.block_change = block_change;
  }
}
class Item {
  int item_num;
  int amount;
  Item(int item_num, int amount) {
    this.item_num = item_num;
    this. amount = amount;
  }
}
class Recipe {
  int item_num;
  int amount;
  int m1, m2, m3, m4, m5, m6, m7, m8, m9;
  Recipe(int item_num, int amount, int m1, int m2, int m3, int m4, int m5, int m6, int m7, int m8, int m9) {
    this.item_num = item_num;
    this.amount = amount;
    this.m1 = m1;
    this.m2 = m2;
    this.m3 = m3;
    this.m4 = m4;
    this.m5 = m5;
    this.m6 = m6;
    this.m7 = m7;
    this.m8 = m8;
    this.m9 = m9;
  }
}
/*-----------------------*/
/*-------地形生成--------*/
void generate_world() {
  float terrainMaxHeight = 50;   // 最大高度を高く設定
  int waterThreshold = 20;       // 水域の閾値
  float noiseScale = 0.02;
  for (int i = 0; i < worldX; i++) {
    for (int j = 0; j < worldZ; j++) {

      float noiseVal = noise(i * noiseScale, j * noiseScale);
      int terrainHeight = int(map(noiseVal, 0, 1, 0, terrainMaxHeight));

      for (int k = 0; k < worldY; k++) {
        if (k < terrainHeight - 3) {
          map[i][j][k] = 12; // 石
        } else if (k < terrainHeight - 1) {
          map[i][j][k] = 10; // 土
        } else if (k == terrainHeight - 1) {
          if (terrainHeight >= waterThreshold) {
            map[i][j][k] = 11; // 草
          } else {
            map[i][j][k] = 10; // 水中の土
          }
        } else if (k < waterThreshold) {
          map[i][j][k] = 7; // 水
        }
      }

      // 洞窟を生成
      if (terrainHeight > waterThreshold + 5) { // 水中以下には生成しない
        if (random(1) < 0.005) { // 1%の確率で洞窟の入り口を作成
          generateCaveEntrance(i, j, terrainHeight);
        }
      }
      // 木を生成（草ブロック上のみ）
      if (terrainHeight >= waterThreshold && map[i][j][terrainHeight - 1] == 11) {
        if (random(1) < 0.03) { // 木を生成する確率はここだよ
          generateTree(i, j, terrainHeight);
        }
      }
    }
  }
}
void generateTree(int x, int z, int baseHeight) {
  int treeHeight = 4 + int(random(3)); // 幹の高さ
  // 幹を生成
  for (int h = 0; h < treeHeight; h++) {
    if (baseHeight + h < worldY) {
      map[x][z][baseHeight + h] = 31; // 幹
    }
  }
  // 葉を生成
  int leafRadius = 2; // 葉の半径
  for (int dx = -leafRadius; dx <= leafRadius; dx++) {
    for (int dz = -leafRadius; dz <= leafRadius; dz++) {
      for (int dy = -1; dy <= 1; dy++) { // 葉の高さ
        if (abs(dx) + abs(dz) + abs(dy) <= leafRadius + 1) {
          int nx = x + dx;
          int ny = baseHeight + treeHeight + dy;
          int nz = z + dz;
          if (nx >= 0 && nx < worldX && nz >= 0 && nz < worldZ && ny >= 0 && ny < worldY) {
            if (map[nx][nz][ny] == 0) { // 空気ブロックにのみ葉を配置
              map[nx][nz][ny] = 32; // 葉
            }
          }
        }
      }
    }
  }
}

void generateCaveEntrance(int x, int z, int surfaceHeight) {
  int caveDepth = 15 + int(random(10)); // 洞窟の最深部
  int caveWidth = 3 + int(random(3));   // 洞窟の幅

  for (int step = 0; step < caveDepth; step++) {
    int currentHeight = surfaceHeight - step;
    int width = caveWidth - step / 5;

    for (int dx = -width; dx <= width; dx++) {
      for (int dz = -width; dz <= width; dz++) {
        if (dx * dx + dz * dz <= width * width) {
          int nx = x + dx;
          int nz = z + dz;
          if (nx >= 0 && nx < worldX && nz >= 0 && nz < worldZ && currentHeight >= 0) {
            map[nx][nz][currentHeight] = 0;
          }
        }
      }
    }
    x += int(random(-1, 2));
    z += int(random(-1, 2));
  }

  generateCaveTunnel(x, z, surfaceHeight - caveDepth);
}

void generateCaveTunnel(int startX, int startZ, int startHeight) {
  int tunnelLength = 30 + int(random(20)); // トンネルの長さ

  int x = startX;
  int z = startZ;
  int y = startHeight;

  for (int t = 0; t < tunnelLength; t++) {
    x += int(random(-1, 2));
    z += int(random(-1, 2));
    y += int(random(-1, 1));

    for (int dx = -2; dx <= 2; dx++) {
      for (int dz = -2; dz <= 2; dz++) {
        for (int dy = -1; dy <= 1; dy++) {
          int nx = x + dx;
          int ny = y + dy;
          int nz = z + dz;
          if (nx >= 0 && nx < worldX && nz >= 0 && nz < worldZ && ny >= 0 && ny < worldY) {
            map[nx][nz][ny] = 0; // 空洞
          }
        }
      }
    }
  }
}

/*-----------------------*/
