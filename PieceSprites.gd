extends Node2D

const b_pawn_sprite = preload("res://ChessPieceSprites/black_pawn.png");
const b_rook_sprite = preload("res://ChessPieceSprites/black_rook.png");
const b_knight_sprite = preload("res://ChessPieceSprites/black_knight.png");
const b_bishop_sprite = preload("res://ChessPieceSprites/black_bishop.png");
const b_queen_sprite = preload("res://ChessPieceSprites/black_queen.png");
const b_king_sprite = preload("res://ChessPieceSprites/black_king.png");

const w_pawn_sprite = preload("res://ChessPieceSprites/white_pawn.png");
const w_rook_sprite = preload("res://ChessPieceSprites/white_rook.png");
const w_knight_sprite = preload("res://ChessPieceSprites/white_knight.png");
const w_bishop_sprite = preload("res://ChessPieceSprites/white_bishop.png");
const w_queen_sprite = preload("res://ChessPieceSprites/white_queen.png");
const w_king_sprite = preload("res://ChessPieceSprites/white_king.png");

# TODO automatically offset, scale, and width, based on screen size
# TODO restrict which chess piece can be selected / moved based on turn (or don't if it's funny)
var bXOffset = 100;
var bYOffset = 100;
var sWidth = 120;
var spriteScale = .12;

var viewSize;

var pieces := [];
var highlight := [];
var selectedPiece;

class PieceSprite:
	var piece = Chessboard.Piece;
	var sprite;

func _ready():
	viewSize = get_viewport().size;
	scale_screen();
	_build_board();

func _build_board():
	pieces.clear();
	for p in Chessboard._board:
		if p != null:
			var pieceSprite = PieceSprite.new();
			pieceSprite.piece = p;
			pieceSprite.sprite = Sprite2D.new();
			pieceSprite.sprite.position = Vector2(p.position.x*sWidth, p.position.y*sWidth);
			pieceSprite.sprite.scale = Vector2(spriteScale, spriteScale);
			pieceSprite.sprite.centered = false;
			pieces.append(pieceSprite);
			add_child(pieceSprite.sprite);
			if p.side == Chessboard.Piece.Side.WHITE:
				match p.type:
					Chessboard.Piece.Type.PAWN:
						pieceSprite.sprite.texture = w_pawn_sprite;
					Chessboard.Piece.Type.ROOK:
						pieceSprite.sprite.texture = w_rook_sprite;
					Chessboard.Piece.Type.KNIGHT:
						pieceSprite.sprite.texture = w_knight_sprite;
					Chessboard.Piece.Type.BISHOP:
						pieceSprite.sprite.texture = w_bishop_sprite;
					Chessboard.Piece.Type.QUEEN:
						pieceSprite.sprite.texture = w_queen_sprite;
					Chessboard.Piece.Type.KING:
						pieceSprite.sprite.texture = w_king_sprite;
					_:
						printerr("Error drawing board: at least one chess piece does not have type");
						break;
			else:
				match p.type:
					Chessboard.Piece.Type.PAWN:
						pieceSprite.sprite.texture = b_pawn_sprite;
					Chessboard.Piece.Type.ROOK:
						pieceSprite.sprite.texture = b_rook_sprite;
					Chessboard.Piece.Type.KNIGHT:
						pieceSprite.sprite.texture = b_knight_sprite;
					Chessboard.Piece.Type.BISHOP:
						pieceSprite.sprite.texture = b_bishop_sprite;
					Chessboard.Piece.Type.QUEEN:
						pieceSprite.sprite.texture = b_queen_sprite;
					Chessboard.Piece.Type.KING:
						pieceSprite.sprite.texture = b_king_sprite;
					_:
						printerr("Error drawing board: at least one chess piece does not have type");
						break;

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clickedValidPiece = false;
		var mousePos = event.position;
		if highlight.is_empty():
			for ps in pieces:
				if ps.sprite.get_rect().has_point(to_local(event.position)):
					pass
				var psS = ps.sprite;
				var psLH = psS.global_position.x;
				var psHH = psLH + sWidth;
				var psLV = psS.global_position.y;
				var psHV = psLV + sWidth;
				if mousePos.x < psHH and mousePos.y < psHV and mousePos.x > psLH and mousePos.y > psLV:
					clickedValidPiece = true;
					selectedPiece = ps;
					highlight.append_array(ps.piece.get_possible_moves());
		else:
			for move in highlight:
				var movePos = Vector2(move.position.x * sWidth + bXOffset, move.position.y * sWidth + bXOffset);
				var mvLH = movePos.x;
				var mvHH = movePos + sWidth;
				var mvLV = movePos.y;
				var mvHV = movePos + sWidth;
				if mousePos.x < mvHH and mousePos.y < mvHV and mousePos.x > mvLH and mousePos.y > mvLV:
					var gameState = move.execute();
					clickedValidPiece = true;
					print_debug(gameState);
		if not clickedValidPiece:
			selectedPiece = null;
			highlight.clear();
		queue_redraw();

func _draw():
	if selectedPiece != null:
		# draw_rect(selectedPiece.sprite.get_rect(), Color(Color.YELLOW, .5), true);
		var selectedHighlight = Rect2(selectedPiece.sprite.position.x, selectedPiece.sprite.position.y, sWidth, sWidth);
		draw_rect(selectedHighlight, Color(Color.BLUE, .5), true);
	for m in highlight:
		var posX = m.position.x * sWidth + bXOffset;
		var posY = m.position.y * sWidth + bYOffset;
		draw_rect(Rect2(posX, posY, sWidth, sWidth), Color(Color.WEB_PURPLE, .5), true);

func scale_screen():
	var viewSize = get_viewport().size;
	sWidth = min(viewSize.x / 8, viewSize.y / 8);
	bXOffset = (viewSize.x - sWidth * 8) / 2;
	bYOffset = (viewSize.y - sWidth * 8) / 2;
	spriteScale = sWidth / 1000.;
	position = Vector2(bXOffset, bYOffset);
	#	for p in pieces:
	#		p.sprite.position = Vector2(p.position.x*sWidth, p.position.y*sWidth);
	#		p.sprite.scale = sWidth;
