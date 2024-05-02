import java.awt.event.KeyAdapter;
import ij.gui.ImageCanvas;
import ij.ImagePlus;

public class CustomCanvas extends ImageCanvas {

    public CustomCanvas(ImagePlus imp, KeyAdapter keyAdapter) {
        super(imp);
        addKeyListener(keyAdapter);
    }
}
