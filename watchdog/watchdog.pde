import oscP5.*;
import netP5.*;

OscP5 oscP5tcpClient;

void setup() {
  oscP5tcpClient = new OscP5(this, "127.0.0.1", 11000, OscP5.TCP);
  noLoop();
}