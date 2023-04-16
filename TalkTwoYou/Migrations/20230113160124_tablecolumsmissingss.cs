using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TalkTwoYou.Migrations
{
    /// <inheritdoc />
    public partial class tablecolumsmissingss : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_UserRefreshTokens_UserDetails_UserId1",
                table: "UserRefreshTokens");

            migrationBuilder.DropIndex(
                name: "IX_UserRefreshTokens_UserId1",
                table: "UserRefreshTokens");

            migrationBuilder.RenameColumn(
                name: "UserId1",
                table: "UserRefreshTokens",
                newName: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "UserId",
                table: "UserRefreshTokens",
                newName: "UserId1");

            migrationBuilder.CreateIndex(
                name: "IX_UserRefreshTokens_UserId1",
                table: "UserRefreshTokens",
                column: "UserId1");

            migrationBuilder.AddForeignKey(
                name: "FK_UserRefreshTokens_UserDetails_UserId1",
                table: "UserRefreshTokens",
                column: "UserId1",
                principalTable: "UserDetails",
                principalColumn: "UserId",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
