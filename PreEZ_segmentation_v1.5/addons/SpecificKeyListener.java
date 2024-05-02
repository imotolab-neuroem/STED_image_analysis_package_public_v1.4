import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;

public class SpecificKeyListener extends KeyAdapter {
    private boolean keyPressed = false;

    public SpecificKeyListener() {
        super();
    }

    @Override
    public void keyTyped(KeyEvent event) {
        if (event.getKeyChar() == 'x') {
            keyPressed = true;
        }
    }

    public boolean isKeyPressed() {
        return keyPressed;
    }
}
