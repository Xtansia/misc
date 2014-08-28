import java.awt.AlphaComposite;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import java.io.File;
import java.io.IOException;

public class Isometric {
	private static int max (int... vals) {
		int max = vals[0];

		for (int i = 1; i < vals.length; i++)
			if (vals[i] > max) max = vals[i];

		return max;
	}

	private static BufferedImage resize (BufferedImage img, int width, int height) {
		BufferedImage res = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
		Graphics2D g2d = res.createGraphics();

		g2d.drawImage(img, 0, 0, width, height, null);

		g2d.dispose();

		return res;
	}

	private static BufferedImage crop (BufferedImage img, int x1, int y1, int x2, int y2) {
		int w = x2 - x1, h = y2 - y1;
		BufferedImage res = new BufferedImage(w, h, BufferedImage.TYPE_INT_ARGB);
		Graphics2D g2d = res.createGraphics();

		g2d.drawImage(img, 0, 0, w, h, x1, y1, x2, y2, null);

		g2d.dispose();

		return res;
	}

	private static BufferedImage rotate90CCW (BufferedImage img) {
		BufferedImage res = new BufferedImage(img.getHeight(), img.getWidth(), BufferedImage.TYPE_INT_ARGB);
		Graphics2D g2d = res.createGraphics();

		g2d.translate(0, res.getHeight());
		g2d.rotate(1.5 * Math.PI);
		g2d.drawImage(img, 0, 0, null);

		g2d.dispose();

		return res;
	}

	private static BufferedImage leftDeform (BufferedImage tile) {
		return leftDeform(tile, 0.5f, 1.25f);
	}

	private static BufferedImage leftDeform (BufferedImage tile, float mult, float hinc) {
		tile = resize(tile, tile.getWidth(), (int)(tile.getHeight() * hinc));
		int w = tile.getWidth(), h = tile.getHeight();
		BufferedImage res = new BufferedImage(w, (int)(h * (1 + mult)), BufferedImage.TYPE_INT_ARGB);
		Graphics2D g2d = res.createGraphics();

		float y = 0;
		BufferedImage crop = null;
		for (int x = 0; x < w; x++) {
			y += mult;
			crop = crop(tile, x, 0, x+1, h);
			g2d.drawImage(crop, x, (int)y, null);
		}

		g2d.dispose();

		return res;
	}

	private static BufferedImage rightDeform (BufferedImage tile) {
		return rightDeform(tile, 0.5f, 1.25f);
	}

	private static BufferedImage rightDeform (BufferedImage tile, float mult, float hinc) {
		tile = resize(tile, tile.getWidth(), (int)(tile.getHeight() * hinc));
		int w = tile.getWidth(), h = tile.getHeight();
		BufferedImage res = new BufferedImage(w, (int)(h * (1 + mult)), BufferedImage.TYPE_INT_ARGB);
		Graphics2D g2d = res.createGraphics();

		float y = (int)(w*0.5f);
		BufferedImage crop = null;
		for (int x = 0; x < w; x++) {
			y -= mult;
			crop = crop(tile, x, 0, x+1, h);
			g2d.drawImage(crop, x, (int)y, null);
		}

		g2d.dispose();

		return res;
	}

	private static BufferedImage topDeform (BufferedImage tile) {
		int w = tile.getWidth(), h = tile.getHeight();

		BufferedImage res = leftDeform(tile, 1, 1);
		res = rotate90CCW(res);
		res = leftDeform(res, 0.5f, 1);
		res = crop(res, 0, h / 2, w * 2, h * 2);

		return res;
	}

	private static enum Face { LEFT, RIGHT, TOP }

	private static BufferedImage expandTile (BufferedImage tile, int size, Face face) {
		int w = tile.getWidth(), h = tile.getHeight();
		BufferedImage res = new BufferedImage(size, size, BufferedImage.TYPE_INT_ARGB);
		Graphics2D g2d = res.createGraphics();

		switch (face) {
		case LEFT:
			g2d.drawImage(tile, size - w, 0, null);
			break;
		case RIGHT:
			g2d.drawImage(tile, 0, 0, null);
			break;
		case TOP:
			g2d.drawImage(tile, 0, size - h, null);
			break;
		}

		g2d.dispose();

		return res;
	}

	private static BufferedImage renderCube (BufferedImage ltile, BufferedImage rtile, BufferedImage ttile) {
		int lw = ltile.getWidth(), lh = ltile.getHeight();
		int rw = rtile.getWidth(), rh = rtile.getHeight();
		int tw = ttile.getWidth(), th = ttile.getHeight();

		assert lw == th && lw % 2 == 0 : "Left tile width must be equal to top tile height, and be even [lw="+lw+",th="+th+"]";
		assert lh == rh && lh % 2 == 0 : "Left tile height must be equal to right tile height, and be even [lw="+lw+",th="+th+"]";
		assert rw == tw && rw % 2 == 0 : "Right tile width must be equal to top tile width, and be even [lw="+lw+",th="+th+"]";
		
		int size = max(lw, lh, rw, rh, tw, th);
		if (lw + lh != size * 2) ltile = expandTile(ltile, size, Face.LEFT);
		if (rw + rh != size * 2) rtile = expandTile(rtile, size, Face.RIGHT);
		if (tw + th != size * 2) ttile = expandTile(ttile, size, Face.TOP);

		ltile = leftDeform(ltile);
		rtile = rightDeform(rtile);
		ttile = topDeform(ttile);

		BufferedImage res = new BufferedImage(size * 2, (int)(size * 2.25f), BufferedImage.TYPE_INT_ARGB);
		Graphics2D g2d = res.createGraphics();

		g2d.drawImage(ttile, 0, 0, null);
		g2d.drawImage(ltile, 0, size / 2, null);
		g2d.drawImage(rtile, size, size / 2, null);

		g2d.dispose();

		res = crop(res, size - lw, (size - th) / 2, size + rw, (int)(size + 1.25 * lh));

		return res;
	}

	private static long ftime, stime;

	private static void time (String section) {
		ftime = System.currentTimeMillis();
		System.out.println(String.format("["+section+"] %.4f seconds", (float)(ftime-stime)/1000f));
		stime = System.currentTimeMillis();
	}

	public static void main (String[] args) throws IOException {
		stime = System.currentTimeMillis();

		// Computer tiles
		BufferedImage c_ltile = ImageIO.read(new File("computerFrontOn.png"));
		BufferedImage c_rtile = ImageIO.read(new File("computerSide.png"));
		BufferedImage c_ttile = ImageIO.read(new File("computerTop.png"));

		time("Reading (computer)");

		// Modem tiles
		BufferedImage m_ltile = ImageIO.read(new File("wirelessModemLeftOn.png"));
		BufferedImage m_rtile = ImageIO.read(new File("wirelessModemFace.png"));
		BufferedImage m_ttile = ImageIO.read(new File("wirelessModemTopOn.png"));

		time("Reading (modem)");

		// Resize the tiles to something more visually appealing
		// 256px tile results in an approx 512px final image
		int desiredComputerTileSize = 2048;
		int scale = desiredComputerTileSize / c_ltile.getWidth();
		c_ltile = resize(c_ltile, c_ltile.getWidth()*scale, c_ltile.getHeight()*scale);
		c_rtile = resize(c_rtile, c_rtile.getWidth()*scale, c_rtile.getHeight()*scale);
		c_ttile = resize(c_ttile, c_ttile.getWidth()*scale, c_ttile.getHeight()*scale);
		
		time("Resizing (computer)");

		m_ltile = resize(m_ltile, m_ltile.getWidth()*scale, m_ltile.getHeight()*scale);
		m_rtile = resize(m_rtile, m_rtile.getWidth()*scale, m_rtile.getHeight()*scale);
		m_ttile = resize(m_ttile, m_ttile.getWidth()*scale, m_ttile.getHeight()*scale);

		time("Resizing (modem)");

		BufferedImage computer = renderCube(c_ltile, c_rtile, c_ttile);

		time("Rendering (computer)");

		BufferedImage modem = renderCube(m_ltile, m_rtile, m_ttile);

		time("Rendering (modem)");

		BufferedImage res = new BufferedImage(computer.getHeight(), computer.getHeight(), BufferedImage.TYPE_INT_ARGB);
		Graphics2D g2d = res.createGraphics();

		g2d.drawImage(computer, scale * 2, 0, null);
		g2d.drawImage(modem, scale * 20, scale / 2 * 23, null);

		g2d.dispose();

		time("Rendering (final result)");

		ImageIO.write(res, "PNG", new File("result.png"));

		time("Writing");
	}
}