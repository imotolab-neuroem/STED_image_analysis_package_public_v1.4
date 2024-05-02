import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;

public class UniqueSpecificKeyListener extends KeyAdapter {
    private boolean keyPressed = false;
    private char targetKey = 't';  // You can change this to the key you want

    @Override
    public void keyTyped(KeyEvent event) {
        if (event.getKeyChar() == targetKey) {
            keyPressed = true;
        }
    }

    public boolean isKeyPressed() {
        return keyPressed;
    }
}
