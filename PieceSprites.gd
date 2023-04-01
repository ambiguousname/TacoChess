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

var bXOffset;
var bYOffset;
var sWidth;
var spriteScale;
var royalScaleX;
var royalScaleY;

var viewSize;

var pieces := [];
var highlight := [];
var selectedPiece;

var boardImage;
var boardRect;

class PieceSprite:
	var piece = Chessboard.Piece;
	var sprite;

func _ready():
	boardImage = Texture2D.new();
	boardImage = load("res://chessboard.png");
	viewSize = get_viewport().size;
	ScaleScreen();
	BuildBoard();

func BuildBoard():
	pieces.clear();
	for p in Chessboard._board:
		if p != null:
			var pieceSprite = PieceSprite.new();
			pieceSprite.piece = p;
			pieceSprite.sprite = Sprite2D.new();
			assignSpritePosition(pieceSprite);
			assignSpriteScale(pieceSprite);
			pieceSprite.sprite.centered = false;
			pieces.append(pieceSprite);
			if p.side == Chessboard.Piece.Side.WHITE:
				match p.type:
					Chessboard.Piece.Type.PAWN:
						pieceSprite.sprite.texture = w_pawn_sprite;
						add_child(pieceSprite.sprite, false, 1);
					Chessboard.Piece.Type.ROOK:
						pieceSprite.sprite.texture = w_rook_sprite;
						add_child(pieceSprite.sprite, false, 1);
					Chessboard.Piece.Type.KNIGHT:
						pieceSprite.sprite.texture = w_knight_sprite;
						add_child(pieceSprite.sprite, false, 1);
					Chessboard.Piece.Type.BISHOP:
						pieceSprite.sprite.texture = w_bishop_sprite;
						add_child(pieceSprite.sprite, false, 1);
					Chessboard.Piece.Type.QUEEN:
						pieceSprite.sprite.texture = w_queen_sprite;
						add_child(pieceSprite.sprite, false, 2);
					Chessboard.Piece.Type.KING:
						pieceSprite.sprite.texture = w_king_sprite;
						add_child(pieceSprite.sprite, false, 2);
					_:
						printerr("Error drawing board: at least one chess piece does not have type");
						break;
			else:
				match p.type:
					Chessboard.Piece.Type.PAWN:
						pieceSprite.sprite.texture = b_pawn_sprite;
						add_child(pieceSprite.sprite, false, 1);
					Chessboard.Piece.Type.ROOK:
						pieceSprite.sprite.texture = b_rook_sprite;
						add_child(pieceSprite.sprite, false, 1);
					Chessboard.Piece.Type.KNIGHT:
						pieceSprite.sprite.texture = b_knight_sprite;
						add_child(pieceSprite.sprite, false, 1);
					Chessboard.Piece.Type.BISHOP:
						pieceSprite.sprite.texture = b_bishop_sprite;
						add_child(pieceSprite.sprite, false, 1);
					Chessboard.Piece.Type.QUEEN:
						pieceSprite.sprite.texture = b_queen_sprite;
						add_child(pieceSprite.sprite, false, 2);
					Chessboard.Piece.Type.KING:
						pieceSprite.sprite.texture = b_king_sprite;
						add_child(pieceSprite.sprite, false, 2);
					_:
						printerr("Error drawing board: at least one chess piece does not have type");
						break;

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clickedValidPiece = false;
		var mousePos = event.position;
		if selectedPiece == null:
			for ps in pieces:
				var psS = ps.sprite;
				var psLH = psS.global_position.x;
				var psHH = psLH + sWidth;
				var psLV
				if ps.piece.type == Chessboard.Piece.Type.KING or ps.piece.type == Chessboard.Piece.Type.QUEEN:
					psLV = psS.global_position.y + sWidth/2;
				else:
					psLV = psS.global_position.y;
				var psHV = psLV + sWidth;
				if mousePos.x < psHH and mousePos.y < psHV and mousePos.x > psLH and mousePos.y > psLV:
					clickedValidPiece = true;
					selectedPiece = ps;
					highlight.append_array(ps.piece.get_possible_moves());
			if not clickedValidPiece:
				selectedPiece = null;
				highlight.clear();
		else:
			for move in highlight:
				var mvLH = (move.position.x * sWidth) + bXOffset;
				var mvHH = mvLH + sWidth;
				var mvLV = ((7-move.position.y) * sWidth) + bYOffset;
				var mvHV = mvLV + sWidth;
				if mousePos.x < mvHH and mousePos.y < mvHV and mousePos.x > mvLH and mousePos.y > mvLV:
					if move.type != Chessboard.Move.Type.PROTECT:
						var gameState = move.execute.call();
						clickedValidPiece = true;
			selectedPiece = null;
			highlight.clear();
		queue_redraw();

func _draw():
	draw_texture_rect(boardImage, boardRect, false, Color(1, 1, 1, 1), false);
	if viewSize != get_viewport().size:
		viewSize = get_viewport().size
		ScaleScreen();
	for p in pieces:
		assignSpritePosition(p);
		if p.piece not in Chessboard._board:
			remove_child(p.sprite);
			pieces.erase(p);
	if selectedPiece != null:
		var selectedHighlight
		if selectedPiece.piece.type == Chessboard.Piece.Type.KING or selectedPiece.piece.type == Chessboard.Piece.Type.QUEEN:
			selectedHighlight = Rect2(selectedPiece.sprite.position.x, selectedPiece.sprite.position.y + sWidth/2, sWidth, sWidth);
		else:
			selectedHighlight = Rect2(selectedPiece.sprite.position.x, selectedPiece.sprite.position.y, sWidth, sWidth);
		draw_rect(selectedHighlight, Color(Color.BLUE, .5), true);
	for m in highlight:
		var posX = (m.position.x* sWidth);
		var posY = ((7-m.position.y) * sWidth);
		draw_rect(Rect2(posX, posY, sWidth, sWidth), Color(Color.WEB_PURPLE, .5), true);

func ScaleScreen():
	sWidth = min(viewSize.x / 8, viewSize.y / 9);
	bXOffset = (viewSize.x - sWidth * 8) / 2;
	bYOffset = max((viewSize.y - sWidth * 8) / 2, sWidth/2);
	spriteScale = sWidth / 1080.;
	royalScaleX = sWidth / 1080.;
	royalScaleY = sWidth / 1640.;
	position = Vector2(bXOffset, bYOffset);
	boardRect = Rect2(0, 0, sWidth * 8, sWidth * 8);
	for p in pieces:
		assignSpritePosition(p);
		assignSpriteScale(p);

func assignSpritePosition(ps: PieceSprite):
	if ps.piece.type == Chessboard.Piece.Type.KING or ps.piece.type == Chessboard.Piece.Type.QUEEN:
		ps.sprite.position = Vector2(ps.piece.position.x*sWidth, (7-ps.piece.position.y)*sWidth - sWidth/2);
	else:
		ps.sprite.position = Vector2(ps.piece.position.x*sWidth, (7-ps.piece.position.y)*sWidth);
	return;

func assignSpriteScale(ps: PieceSprite):
	if ps.piece.type == Chessboard.Piece.Type.KING or ps.piece.type == Chessboard.Piece.Type.QUEEN:
		ps.sprite.scale = Vector2(royalScaleX, royalScaleY *1.5);
	else:
		ps.sprite.scale = Vector2(spriteScale, spriteScale);
