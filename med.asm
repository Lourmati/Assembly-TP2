;;; Programme Assembleur Sous-programmes TP2
;;;Écriture, lecture et affichage dans un fichier existant ou créé
;;; Le programme affiche les lignes inférieures à 80 caractères
;;; Auteur: Oussama Lourhmati

	%include "ut_chaines.asm"
	%include "ut_fichiers.asm"

segment	.data
	
message_erreur:	db "Nombre d'arguments invalide",0
descripteur:	dd 1


segment	.bss
	
length:	resd 1
chaine:	resb 81
i:	resb 1 ;; compteur i
	
segment .text
	global _start	
_start:
	
;;;Verification du nombre d’arguments
	cmp dword [esp] , 2
	jne sortie2

;;;Verifier si le fichier existe
	push dword[esp+8]
	push 0
	call fichier_existe
	pop eax
	cmp eax, 1
	je ouverture
	
;;; Creation du fichier, s'il n'existe pas
creer_fichier:
	push dword[esp+8] ;;endroit ou il y a le nom du fichier
	push 101o
    	 push 0
	call ouvrir_fichier
	pop dword [descripteur]
	add esp,8
	jmp lecture
	
;;; Ouverture du fichier, s'il est existant
ouverture:
	push dword[esp+8]
	push 201o
	push 0
	call ouvrir_fichier
	pop dword [descripteur]
	add esp, 8

;;; On call taille_fichier, pour avoir la taille
	push dword [esp+8]
	push 0
	call taille_fichier
	pop eax
	add esp, 4

;;; Deplacement a la fin du fichier existant, pour y ajouter du texte
	push dword [esp+4] ;;descripteur de fichier
	push dword [esp+8]
	call deplacer_fichier
	add esp, 8
	
;;; Lecture d'une ligne, de la chaine
lecture:
	push 81
	push chaine
	push 0
	call lire_ch
	pop dword[length]
	add esp,8
;;; -1 si c'est trop grand, on revient a la lecture et on ignore la chaine
	cmp dword[length],-1
	je lecture
;;; 1 si c'est un retour, on va dans l'incrementation du compteur
	cmp dword[length],1
	je incrementation

	call ecriture ;;on va écrire dans le fichier
	jmp lecture ;;je boucle le tout

;;; fonction pour l'ecriture dans le fichier
ecriture:
	push ebp;; Je push mes registres
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	mov eax, 3 ;;Saisir du texte, dans chaine
	mov ebx, 0
	mov ecx, chaine
	mov edx,81 ;;Taille maximale (avec le retour) 
	int 0x80

	pop edx; Restaurer les registres
	pop ecx
	pop ebx
	pop eax
	pop ebp
	RET
	

;;; incrementation, si on a un lu un retour
incrementation:
	inc byte[i]
	cmp dword[i],2 ;;si =2, on affiche le fichier
	je affichage
	cmp dword[i],3 ;;si =3, on quitte le programme
	je quitter
	jmp lecture ;;on revient a la lecture pour le reste

affichage:
	push dword [esp+4] ;;comme dans la fonction fournie (affiche_n1)
	call affiche 
	add esp,4
	call nouvelle_ligne
	jmp lecture

sortie2: 
	push message_erreur
	call affiche2
	add esp, 4

quitter:
	mov eax, 1
	mov ebx, 0
	int 0x80

affiche2:
	push ebp
	mov  ebp, esp
	push eax
	push ebx
	push ecx
	push edx

	mov eax, 4
	mov ebx, 2
	mov ecx, [ebp + 8]

	;; Appel de la fonction taille_ch
	push ecx
	push 0			; pour la taille
	call taille_ch
	pop  edx		; edx prend la taille
	add esp, 4		; enleve un parametre

	int 0x80

	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
	ret



