using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TalkTwoYou.Migrations
{
    /// <inheritdoc />
    public partial class tableRemakeV1 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_RegisterStatus_UserId",
                table: "RegisterStatus",
                column: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_RegisterStatus_UserDetails_UserId",
                table: "RegisterStatus",
                column: "UserId",
                principalTable: "UserDetails",
                principalColumn: "UserId",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_RegisterStatus_UserDetails_UserId",
                table: "RegisterStatus");

            migrationBuilder.DropIndex(
                name: "IX_RegisterStatus_UserId",
                table: "RegisterStatus");
        }
    }
}
