import java.util.Map;

// MAP AND COORDINATES
PImage bg;

// google maps constants (inaccurate observations)
double zoom11_half_width = 0.2193835;
double zoom11_half_height = 0.157381;
double zoom12_half_width = zoom11_half_width / 2;
double zoom12_half_height = zoom11_half_height / 2;
double zoom13_half_width = zoom12_half_width / 2;
double zoom13_half_height = zoom12_half_height / 2;

// Bucharest center (near Universitate).
// Pictures were taken from http://maps.googleapis.com/maps/api/staticmap?center=44.4378257,26.0946376&zoom=11&size=640x640  // 640x640 is the maximum
double city_center_y = 44.4378257;
double city_center_x = 26.0946376;

String image_filename = "b12.png";
double margin_y0 = city_center_y + zoom12_half_height;
double margin_y1 = city_center_y - zoom12_half_height;
double margin_x0 = city_center_x - zoom12_half_width;
double margin_x1 = city_center_x + zoom12_half_width;


double coord_width = margin_x1 - margin_x0;
double coord_height = margin_y0 - margin_y1;

// check if coordinates are inside the map
boolean is_inside(double x, double y) {
  return (margin_y0 > y && margin_y1 < y && margin_x0 < x && margin_x1 > x);
}

// Transform coordinates to screen coordinates
int c2s_x(double x) {
  return (int)((640 * x - 640 * margin_x0) / coord_width);
}
int c2s_y(double y) {
  return (int)((640 * margin_y0 - 640 * y) / coord_height);  
}

// FILE AND INPUT
BufferedReader reader;

// Metadata for current frame
String timestamp = "";
String car_count = "0";
String old_positions_str = "";
String positions_str = "";


int counter = 0;
//color[] palette = {#000000, #00FF00, #800000, #FF0000, #0000FF, #800080, #A0A0A4, #008000, #808080, #808000, #000080, #FFFF00, #FFFBF0, #008080, #C0C0C0, #FF00FF, #C0DCC0, #00FFFF, #A6CAF0, #FFFFFF};
color[] palette = {
  #704000,
  #505050,
  #004070,
  #A00000,
  #00A000,
  #0000A0,
  #0000FF,
  #00FF00,
  #FF0000,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0
};
Map<String,Integer> color_map = new HashMap<String,Integer>();
color color_from_str(String input) {
  if (color_map.containsKey(input)) {
    color result = color(color_map.get(input)); 
    return result;
  }
  println(input + " - " + counter);
  color result = palette[counter];
  counter += 1;
  color_map.put(input, result); 
  return result;
}


Boolean read_data() {
  try {
    timestamp = reader.readLine();
    car_count = reader.readLine();
    positions_str = reader.readLine();
    return timestamp != null && car_count != null && positions_str != null;
  } catch (IOException e) {
    e.printStackTrace();
    return false;
  }
}

PFont font;

void setup() {
  size(640, 640);
  frameRate(30);
  bg = loadImage(image_filename);
  font = createFont("Arial",14,true);
  reader = createReader("cpositions.txt");
}

void plot(double x, double y, color point_color) {
  if (!is_inside(x, y)) {
   return;
  }
  // Transform to screen coordinates
  int sx = c2s_x(x);
  int sy = c2s_y(y);
  
  int glow_width = 5;
  int circle_width = 4;
  fill(point_color);
  ellipse(sx, sy, glow_width, glow_width);
  //fill(0);
  //ellipse(sx, sy, circle_width, circle_width);
}

void draw_meta() {
  textFont(font);
  fill(0);
  text(timestamp, 10, height - 10);
  text("Cars on the road: " + car_count, width / 2, height - 10);
}

void draw() {
  background(bg);
  if (!read_data()) {
    noLoop();
    return;
  }
  noStroke(); 
  smooth();
  
  String[] positions_strs = split(positions_str, ' ');
  for (int i = 0; i < positions_strs.length; i += 3) {
    if (positions_strs[i].isEmpty() || positions_strs[i + 1].isEmpty() || positions_strs[i + 2].isEmpty()) {
      continue;
    }
    double x = Double.parseDouble(positions_strs[i]);
    double y = Double.parseDouble(positions_strs[i + 1]);
    String company_id = positions_strs[i + 2];
    plot(x, y, color_from_str(company_id));
  }

  draw_meta();
  
  //saveFrame("frames/####.png");
}

